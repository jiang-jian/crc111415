package com.holox.ailand_pos.mingtech

import android.content.Context
import android.hardware.usb.*
import android.util.Log
import kotlinx.coroutines.*
import java.util.concurrent.atomic.AtomicBoolean

/**
 * USB HID通信管理器
 * 负责与明泰MT3读卡器的底层USB通信
 */
class UsbHidManager(private val context: Context) {
    companion object {
        private const val TAG = "UsbHidManager"
        private const val TIMEOUT_MS = 1000
        private const val READ_TIMEOUT_MS = 2000
    }
    
    private val usbManager: UsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
    
    @Volatile
    private var connection: UsbDeviceConnection? = null
    
    @Volatile
    private var device: UsbDevice? = null
    
    @Volatile
    private var usbInterface: UsbInterface? = null
    
    @Volatile
    private var inEndpoint: UsbEndpoint? = null
    
    @Volatile
    private var outEndpoint: UsbEndpoint? = null
    
    private var readJob: Job? = null
    private val isReading = AtomicBoolean(false)
    
    // 回调接口
    var onDataReceived: ((ByteArray) -> Unit)? = null
    var onError: ((String) -> Unit)? = null
    var onDisconnected: (() -> Unit)? = null
    
    /**
     * 查找明泰读卡器设备
     */
    fun findDevice(): UsbDevice? {
        val deviceList = usbManager.deviceList
        Log.d(TAG, "扫描USB设备，共${deviceList.size}个")
        
        for ((_, device) in deviceList) {
            if (device.vendorId == Protocol.VENDOR_ID && device.productId == Protocol.PRODUCT_ID) {
                Log.d(TAG, "找到明泰读卡器: ${device.deviceName}")
                return device
            }
        }
        
        Log.w(TAG, "未找到明泰读卡器 (VID:0x${Protocol.VENDOR_ID.toString(16)}, PID:0x${Protocol.PRODUCT_ID.toString(16)})")
        return null
    }
    
    /**
     * 检查是否有设备权限
     */
    fun hasPermission(device: UsbDevice): Boolean {
        return usbManager.hasPermission(device)
    }
    
    /**
     * 打开设备连接
     * 
     * @param targetDevice 目标USB设备
     * @return 成功返回true，失败返回false
     */
    fun open(targetDevice: UsbDevice): Boolean {
        try {
            Log.d(TAG, "========== 打开USB设备 ==========")
            Log.d(TAG, "设备: ${targetDevice.deviceName}")
            Log.d(TAG, "VID: 0x${targetDevice.vendorId.toString(16)}, PID: 0x${targetDevice.productId.toString(16)}")
            
            // 检查权限
            if (!usbManager.hasPermission(targetDevice)) {
                Log.e(TAG, "没有USB权限")
                return false
            }
            
            // 查找HID接口
            var hidInterface: UsbInterface? = null
            for (i in 0 until targetDevice.interfaceCount) {
                val intf = targetDevice.getInterface(i)
                if (intf.interfaceClass == UsbConstants.USB_CLASS_HID) {
                    hidInterface = intf
                    Log.d(TAG, "找到HID接口: index=$i, class=${intf.interfaceClass}")
                    break
                }
            }
            
            if (hidInterface == null) {
                Log.e(TAG, "未找到HID接口")
                return false
            }
            
            // 打开设备
            val conn = usbManager.openDevice(targetDevice)
            if (conn == null) {
                Log.e(TAG, "无法打开设备连接")
                return false
            }
            Log.d(TAG, "✓ 设备连接已打开")
            
            // 声明接口
            if (!conn.claimInterface(hidInterface, true)) {
                Log.e(TAG, "无法声明接口")
                conn.close()
                return false
            }
            Log.d(TAG, "✓ 接口声明成功")
            
            // 查找端点
            var inEp: UsbEndpoint? = null
            var outEp: UsbEndpoint? = null
            
            for (i in 0 until hidInterface.endpointCount) {
                val endpoint = hidInterface.getEndpoint(i)
                Log.d(TAG, "端点$i: address=0x${endpoint.address.toString(16)}, direction=${if (endpoint.direction == UsbConstants.USB_DIR_IN) "IN" else "OUT"}, type=${endpoint.type}")
                
                when (endpoint.address.toInt()) {
                    Protocol.ENDPOINT_IN -> {
                        inEp = endpoint
                        Log.d(TAG, "✓ 找到IN端点: 0x${endpoint.address.toString(16)}, maxPacket=${endpoint.maxPacketSize}")
                    }
                    Protocol.ENDPOINT_OUT -> {
                        outEp = endpoint
                        Log.d(TAG, "✓ 找到OUT端点: 0x${endpoint.address.toString(16)}, maxPacket=${endpoint.maxPacketSize}")
                    }
                }
            }
            
            if (inEp == null) {
                Log.e(TAG, "未找到IN端点(0x81)")
                conn.releaseInterface(hidInterface)
                conn.close()
                return false
            }
            
            // OUT端点可选（某些设备可能只支持被动读取）
            if (outEp == null) {
                Log.w(TAG, "未找到OUT端点(0x01)，仅支持被动读取模式")
            }
            
            // 保存状态
            this.device = targetDevice
            this.connection = conn
            this.usbInterface = hidInterface
            this.inEndpoint = inEp
            this.outEndpoint = outEp
            
            // 启动读取线程
            startReadLoop()
            
            Log.d(TAG, "========== 设备打开成功 ==========")
            return true
            
        } catch (e: Exception) {
            Log.e(TAG, "打开设备失败: ${e.message}", e)
            close()
            return false
        }
    }
    
    /**
     * 关闭设备连接
     */
    fun close() {
        Log.d(TAG, "关闭USB连接")
        
        // 停止读取线程
        stopReadLoop()
        
        // 释放接口
        try {
            usbInterface?.let { intf ->
                connection?.releaseInterface(intf)
            }
        } catch (e: Exception) {
            Log.e(TAG, "释放接口失败: ${e.message}")
        }
        
        // 关闭连接
        try {
            connection?.close()
        } catch (e: Exception) {
            Log.e(TAG, "关闭连接失败: ${e.message}")
        }
        
        connection = null
        device = null
        usbInterface = null
        inEndpoint = null
        outEndpoint = null
        
        Log.d(TAG, "USB连接已关闭")
    }
    
    /**
     * 发送数据到设备
     * 
     * @param data 要发送的数据（最多64字节）
     * @return 成功返回true
     */
    fun send(data: ByteArray): Boolean {
        val conn = connection
        val ep = outEndpoint
        
        if (conn == null || ep == null) {
            Log.e(TAG, "发送失败: 设备未连接或无OUT端点")
            return false
        }
        
        try {
            Log.d(TAG, "发送数据: ${data.size}字节")
            Log.d(TAG, "数据内容: ${data.take(Math.min(32, data.size)).joinToString(" ") { "%02X".format(it) }}${if (data.size > 32) "..." else ""}")
            
            // 使用bulkTransfer或interruptTransfer（根据端点类型）
            val result = if (ep.type == UsbConstants.USB_ENDPOINT_XFER_INT) {
                conn.bulkTransfer(ep, data, data.size, TIMEOUT_MS)
            } else {
                conn.bulkTransfer(ep, data, data.size, TIMEOUT_MS)
            }
            
            if (result < 0) {
                Log.e(TAG, "发送失败: 返回码=$result")
                return false
            }
            
            Log.d(TAG, "✓ 发送成功: $result 字节")
            return true
            
        } catch (e: Exception) {
            Log.e(TAG, "发送异常: ${e.message}", e)
            onError?.invoke("发送数据失败: ${e.message}")
            return false
        }
    }
    
    /**
     * 同步接收数据（带超时）
     * 
     * @param timeoutMs 超时时间（毫秒）
     * @return 接收到的数据，超时或失败返回null
     */
    fun receive(timeoutMs: Int = READ_TIMEOUT_MS): ByteArray? {
        val conn = connection
        val ep = inEndpoint
        
        if (conn == null || ep == null) {
            Log.e(TAG, "接收失败: 设备未连接")
            return null
        }
        
        try {
            val buffer = ByteArray(Protocol.PACKET_SIZE)
            val result = conn.bulkTransfer(ep, buffer, buffer.size, timeoutMs)
            
            if (result < 0) {
                // 超时或错误
                return null
            }
            
            if (result > 0) {
                val data = buffer.copyOf(result)
                Log.d(TAG, "接收数据: $result 字节")
                Log.d(TAG, "数据内容: ${data.joinToString(" ") { "%02X".format(it) }}")
                return data
            }
            
            return null
            
        } catch (e: Exception) {
            Log.e(TAG, "接收异常: ${e.message}", e)
            return null
        }
    }
    
    /**
     * 启动后台读取循环
     */
    private fun startReadLoop() {
        if (isReading.get()) {
            Log.w(TAG, "读取循环已在运行")
            return
        }
        
        isReading.set(true)
        
        readJob = CoroutineScope(Dispatchers.IO).launch {
            Log.d(TAG, "启动读取循环")
            val buffer = ByteArray(Protocol.PACKET_SIZE)
            
            while (isActive && isReading.get()) {
                try {
                    val conn = connection ?: break
                    val ep = inEndpoint ?: break
                    
                    // 阻塞读取（2秒超时）
                    val len = conn.bulkTransfer(ep, buffer, buffer.size, READ_TIMEOUT_MS)
                    
                    if (len > 0) {
                        // 过滤空帧（全0）
                        val data = buffer.copyOf(len)
                        if (data.any { it != 0.toByte() }) {
                            Log.d(TAG, "[异步] 接收数据: $len 字节")
                            Log.d(TAG, "[异步] 内容: ${data.take(32).joinToString(" ") { "%02X".format(it) }}${if (len > 32) "..." else ""}")
                            
                            // 回调到上层
                            withContext(Dispatchers.Main) {
                                onDataReceived?.invoke(data)
                            }
                        }
                    } else if (len < 0) {
                        // 错误或断开
                        Log.w(TAG, "读取错误: $len")
                        delay(100)  // 避免CPU占用过高
                    }
                    
                } catch (e: CancellationException) {
                    Log.d(TAG, "读取循环已取消")
                    break
                } catch (e: Exception) {
                    Log.e(TAG, "读取异常: ${e.message}")
                    withContext(Dispatchers.Main) {
                        onError?.invoke("读取数据失败: ${e.message}")
                    }
                    delay(1000)  // 错误后等待1秒再重试
                }
            }
            
            Log.d(TAG, "读取循环已退出")
            
            // 通知断开
            if (connection == null) {
                withContext(Dispatchers.Main) {
                    onDisconnected?.invoke()
                }
            }
        }
    }
    
    /**
     * 停止读取循环
     */
    private fun stopReadLoop() {
        isReading.set(false)
        readJob?.cancel()
        readJob = null
    }
    
    /**
     * 检查连接状态
     */
    fun isConnected(): Boolean {
        return connection != null && device != null
    }
    
    /**
     * 获取设备信息
     */
    fun getDeviceInfo(): Map<String, Any>? {
        val dev = device ?: return null
        
        return mapOf(
            "deviceName" to dev.deviceName,
            "vendorId" to dev.vendorId,
            "productId" to dev.productId,
            "manufacturer" to (dev.manufacturerName ?: "MingTech"),
            "product" to (dev.productName ?: "MT3-URF1-R333"),
            "serialNumber" to (dev.serialNumber ?: "Unknown"),
            "deviceId" to dev.deviceId,
            "isConnected" to isConnected()
        )
    }
}
