package com.holox.ailand_pos.mingtech

import android.util.Log
import kotlinx.coroutines.*
import java.util.concurrent.TimeoutException

/**
 * M1卡片操作服务
 * 封装寻卡、认证、读块等操作
 */
class M1CardService(private val hidManager: UsbHidManager) {
    companion object {
        private const val TAG = "M1CardService"
        private const val RESPONSE_TIMEOUT = 3000L  // 响应超时3秒
    }
    
    // 等待响应的锁
    private val responseLock = Object()
    @Volatile
    private var pendingResponse: ByteArray? = null
    
    // 当前卡片UID
    @Volatile
    private var currentUid: ByteArray? = null
    
    // 回调
    var onCardDetected: ((uid: ByteArray, cardType: String) -> Unit)? = null
    var onAuthResult: ((success: Boolean, message: String) -> Unit)? = null
    var onBlockRead: ((blockData: ByteArray) -> Unit)? = null
    var onError: ((errorCode: String, message: String) -> Unit)? = null
    
    init {
        // 注册数据接收回调
        hidManager.onDataReceived = { data ->
            handleResponse(data)
        }
    }
    
    /**
     * 寻卡（轮询模式）
     * 
     * @return 卡片UID，无卡返回null
     */
    suspend fun pollCard(): ByteArray? = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "========== 寻卡操作 ==========")
            
            // 构建寻卡命令
            val command = Protocol.buildPollCardCommand()
            
            // 发送命令
            if (!hidManager.send(command)) {
                Log.e(TAG, "发送寻卡命令失败")
                return@withContext null
            }
            
            // 等待响应
            val response = waitForResponse(RESPONSE_TIMEOUT)
            if (response == null) {
                // 超时表示无卡（正常情况）
                return@withContext null
            }
            
            // 解析响应
            val (status, payload) = Protocol.parseResponse(response) ?: run {
                Log.e(TAG, "解析寻卡响应失败")
                return@withContext null
            }
            
            when (status) {
                Protocol.Status.SUCCESS -> {
                    if (payload.isEmpty()) {
                        Log.d(TAG, "未检测到卡片")
                        return@withContext null
                    }
                    
                    // 提取UID（payload前4或7字节）
                    val uidLength = when {
                        payload.size >= 7 && payload[0] != 0.toByte() -> Protocol.M1.UID_LENGTH_7
                        payload.size >= 4 -> Protocol.M1.UID_LENGTH_4
                        else -> {
                            Log.e(TAG, "UID数据不完整: ${payload.size}字节")
                            return@withContext null
                        }
                    }
                    
                    val uid = payload.copyOfRange(0, uidLength)
                    currentUid = uid
                    
                    // 推断卡片类型
                    val cardType = when (uidLength) {
                        Protocol.M1.UID_LENGTH_4 -> "Mifare Classic 1K"
                        Protocol.M1.UID_LENGTH_7 -> "Mifare Classic 4K"
                        else -> "Unknown Mifare"
                    }
                    
                    Log.d(TAG, "✓ 检测到卡片")
                    Log.d(TAG, "  UID: ${Protocol.formatUid(uid)}")
                    Log.d(TAG, "  类型: $cardType")
                    
                    // 触发回调
                    onCardDetected?.invoke(uid, cardType)
                    
                    return@withContext uid
                }
                
                Protocol.Status.NO_CARD -> {
                    Log.d(TAG, "未检测到卡片")
                    return@withContext null
                }
                
                else -> {
                    Log.e(TAG, "寻卡失败，状态码: 0x${status.toString(16)}")
                    onError?.invoke("POLL_FAILED", "寻卡失败，状态码: 0x${status.toString(16)}")
                    return@withContext null
                }
            }
            
        } catch (e: TimeoutException) {
            // 超时表示无卡（正常）
            return@withContext null
        } catch (e: Exception) {
            Log.e(TAG, "寻卡异常: ${e.message}", e)
            onError?.invoke("POLL_ERROR", "寻卡异常: ${e.message}")
            return@withContext null
        }
    }
    
    /**
     * 认证扇区
     * 
     * @param sector 扇区号（0-15）
     * @param key 密钥（6字节）
     * @param useKeyA true=使用KeyA，false=使用KeyB
     * @return 认证成功返回true
     */
    suspend fun authSector(sector: Int, key: ByteArray, useKeyA: Boolean = true): Boolean = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "========== 认证扇区 ==========")
            Log.d(TAG, "扇区: $sector")
            Log.d(TAG, "密钥类型: ${if (useKeyA) "KeyA" else "KeyB"}")
            Log.d(TAG, "密钥: ${key.joinToString(" ") { "%02X".format(it) }}")
            
            // 检查是否有卡片
            if (currentUid == null) {
                Log.e(TAG, "认证失败: 未检测到卡片，请先执行寻卡")
                onAuthResult?.invoke(false, "未检测到卡片")
                return@withContext false
            }
            
            // 构建认证命令
            val command = Protocol.buildAuthCommand(sector, key, useKeyA)
            
            // 发送命令
            if (!hidManager.send(command)) {
                Log.e(TAG, "发送认证命令失败")
                onAuthResult?.invoke(false, "发送命令失败")
                return@withContext false
            }
            
            // 等待响应
            val response = waitForResponse(RESPONSE_TIMEOUT)
            if (response == null) {
                Log.e(TAG, "认证超时")
                onAuthResult?.invoke(false, "认证超时")
                return@withContext false
            }
            
            // 解析响应
            val (status, _) = Protocol.parseResponse(response) ?: run {
                Log.e(TAG, "解析认证响应失败")
                onAuthResult?.invoke(false, "响应解析失败")
                return@withContext false
            }
            
            when (status) {
                Protocol.Status.SUCCESS -> {
                    Log.d(TAG, "✓ 认证成功")
                    onAuthResult?.invoke(true, "认证成功")
                    return@withContext true
                }
                
                Protocol.Status.AUTH_FAILED -> {
                    Log.e(TAG, "✗ 认证失败：密钥错误")
                    onAuthResult?.invoke(false, "密钥错误")
                    return@withContext false
                }
                
                Protocol.Status.NO_CARD -> {
                    Log.e(TAG, "✗ 认证失败：卡片丢失")
                    onAuthResult?.invoke(false, "卡片丢失")
                    currentUid = null  // 清除当前卡片
                    return@withContext false
                }
                
                else -> {
                    Log.e(TAG, "✗ 认证失败，状态码: 0x${status.toString(16)}")
                    onAuthResult?.invoke(false, "认证失败 (0x${status.toString(16)})")
                    return@withContext false
                }
            }
            
        } catch (e: TimeoutException) {
            Log.e(TAG, "认证超时: ${e.message}")
            onAuthResult?.invoke(false, "操作超时")
            return@withContext false
        } catch (e: Exception) {
            Log.e(TAG, "认证异常: ${e.message}", e)
            onAuthResult?.invoke(false, "认证异常: ${e.message}")
            return@withContext false
        }
    }
    
    /**
     * 读取块数据
     * 
     * @param block 块号（0-63 for 1K, 0-255 for 4K）
     * @return 块数据（16字节），失败返回null
     */
    suspend fun readBlock(block: Int): ByteArray? = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "========== 读取块 ==========")
            Log.d(TAG, "块号: $block")
            
            // 检查是否有卡片
            if (currentUid == null) {
                Log.e(TAG, "读取失败: 未检测到卡片")
                onError?.invoke("NO_CARD", "未检测到卡片")
                return@withContext null
            }
            
            // 构建读取命令
            val command = Protocol.buildReadBlockCommand(block)
            
            // 发送命令
            if (!hidManager.send(command)) {
                Log.e(TAG, "发送读取命令失败")
                onError?.invoke("SEND_FAILED", "发送命令失败")
                return@withContext null
            }
            
            // 等待响应
            val response = waitForResponse(RESPONSE_TIMEOUT)
            if (response == null) {
                Log.e(TAG, "读取超时")
                onError?.invoke("TIMEOUT", "读取超时")
                return@withContext null
            }
            
            // 解析响应
            val (status, payload) = Protocol.parseResponse(response) ?: run {
                Log.e(TAG, "解析读取响应失败")
                onError?.invoke("PARSE_FAILED", "响应解析失败")
                return@withContext null
            }
            
            when (status) {
                Protocol.Status.SUCCESS -> {
                    if (payload.size != Protocol.M1.BLOCK_SIZE) {
                        Log.e(TAG, "✗ 块数据长度错误: ${payload.size}字节（期望16字节）")
                        onError?.invoke("INVALID_DATA", "数据长度错误")
                        return@withContext null
                    }
                    
                    Log.d(TAG, "✓ 读取成功")
                    Log.d(TAG, "  数据: ${Protocol.formatBlockData(payload)}")
                    
                    // 触发回调
                    onBlockRead?.invoke(payload)
                    
                    return@withContext payload
                }
                
                Protocol.Status.READ_FAILED -> {
                    Log.e(TAG, "✗ 读取失败：扇区未认证或读取错误")
                    onError?.invoke("READ_FAILED", "读取失败，请先认证扇区")
                    return@withContext null
                }
                
                Protocol.Status.NO_CARD -> {
                    Log.e(TAG, "✗ 读取失败：卡片丢失")
                    onError?.invoke("NO_CARD", "卡片丢失")
                    currentUid = null
                    return@withContext null
                }
                
                else -> {
                    Log.e(TAG, "✗ 读取失败，状态码: 0x${status.toString(16)}")
                    onError?.invoke("READ_ERROR", "读取失败 (0x${status.toString(16)})")
                    return@withContext null
                }
            }
            
        } catch (e: TimeoutException) {
            Log.e(TAG, "读取超时: ${e.message}")
            onError?.invoke("TIMEOUT", "操作超时")
            return@withContext null
        } catch (e: Exception) {
            Log.e(TAG, "读取异常: ${e.message}", e)
            onError?.invoke("READ_ERROR", "读取异常: ${e.message}")
            return@withContext null
        }
    }
    
    /**
     * 获取当前卡片UID
     */
    fun getCurrentUid(): ByteArray? = currentUid
    
    /**
     * 清除当前卡片状态
     */
    fun clearCard() {
        currentUid = null
        Log.d(TAG, "已清除卡片状态")
    }
    
    /**
     * 处理接收到的响应数据
     */
    private fun handleResponse(data: ByteArray) {
        synchronized(responseLock) {
            pendingResponse = data
            responseLock.notifyAll()
        }
    }
    
    /**
     * 等待响应数据
     * 
     * @param timeoutMs 超时时间（毫秒）
     * @return 响应数据，超时返回null
     */
    private fun waitForResponse(timeoutMs: Long): ByteArray? {
        synchronized(responseLock) {
            pendingResponse = null
            
            val startTime = System.currentTimeMillis()
            while (pendingResponse == null) {
                val elapsed = System.currentTimeMillis() - startTime
                if (elapsed >= timeoutMs) {
                    throw TimeoutException("等待响应超时")
                }
                
                val remaining = timeoutMs - elapsed
                try {
                    responseLock.wait(remaining)
                } catch (e: InterruptedException) {
                    Thread.currentThread().interrupt()
                    throw TimeoutException("等待被中断")
                }
            }
            
            return pendingResponse
        }
    }
    
    /**
     * 启动自动寻卡循环（用于被动监听刷卡事件）
     */
    fun startAutoPolling(intervalMs: Long = 500): Job {
        return CoroutineScope(Dispatchers.IO).launch {
            Log.d(TAG, "启动自动寻卡循环（间隔${intervalMs}ms）")
            
            var lastUid: String? = null
            
            while (isActive) {
                try {
                    val uid = pollCard()
                    
                    if (uid != null) {
                        val uidStr = Protocol.formatUid(uid)
                        // 只在UID变化时触发回调（避免重复）
                        if (uidStr != lastUid) {
                            lastUid = uidStr
                            Log.d(TAG, "[自动寻卡] 检测到新卡: $uidStr")
                        }
                    } else {
                        // 无卡时重置
                        if (lastUid != null) {
                            Log.d(TAG, "[自动寻卡] 卡片移除")
                            lastUid = null
                        }
                    }
                    
                } catch (e: Exception) {
                    Log.e(TAG, "自动寻卡异常: ${e.message}")
                }
                
                delay(intervalMs)
            }
            
            Log.d(TAG, "自动寻卡循环已停止")
        }
    }
}
