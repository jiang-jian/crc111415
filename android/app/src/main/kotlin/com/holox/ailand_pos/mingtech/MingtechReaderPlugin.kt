package com.holox.ailand_pos.mingtech

import android.content.Context
import android.hardware.usb.UsbDevice
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

/**
 * 明泰MT3-URF1-R333读卡器Flutter插件
 * 
 * 提供MethodChannel和EventChannel接口供Flutter调用
 */
class MingtechReaderPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    companion object {
        private const val TAG = "MingtechReaderPlugin"
        private const val METHOD_CHANNEL_NAME = "mingtech_reader/method"
        private const val EVENT_CHANNEL_NAME = "mingtech_reader/event"
    }
    
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    
    private var context: Context? = null
    private var hidManager: UsbHidManager? = null
    private var cardService: M1CardService? = null
    private var usbReceiver: UsbReceiver? = null
    
    private var autoPollingJob: Job? = null
    
    // 设备状态
    @Volatile
    private var isInitialized = false
    @Volatile
    private var currentDevice: UsbDevice? = null
    
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "插件已附加到引擎")
        
        context = binding.applicationContext
        
        // 创建MethodChannel
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)
        
        // 创建EventChannel
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)
        
        Log.d(TAG, "通道已创建")
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "插件已从引擎分离")
        
        // 清理资源
        cleanup()
        
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        
        context = null
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "收到方法调用: ${call.method}")
        
        when (call.method) {
            "init" -> handleInit(result)
            "getDeviceInfo" -> handleGetDeviceInfo(result)
            "authSector" -> handleAuthSector(call, result)
            "readBlock" -> handleReadBlock(call, result)
            "startAutoPolling" -> handleStartAutoPolling(result)
            "stopAutoPolling" -> handleStopAutoPolling(result)
            else -> result.notImplemented()
        }
    }
    
    /**
     * 初始化读卡器
     */
    private fun handleInit(result: MethodChannel.Result) {
        val ctx = context
        if (ctx == null) {
            result.error("NO_CONTEXT", "Context未初始化", null)
            return
        }
        
        try {
            Log.d(TAG, "========== 初始化明泰读卡器 ==========")
            
            // 创建HID管理器
            hidManager = UsbHidManager(ctx)
            
            // 查找设备
            val device = hidManager?.findDevice()
            if (device == null) {
                Log.w(TAG, "未找到明泰读卡器")
                result.success(mapOf(
                    "success" to false,
                    "message" to "未找到明泰读卡器，请检查设备连接"
                ))
                return
            }
            
            currentDevice = device
            
            // 注册USB接收器
            usbReceiver = UsbReceiver().apply {
                onDeviceAttached = { dev ->
                    sendEvent(mapOf(
                        "event" to "device_attached",
                        "deviceName" to dev.deviceName
                    ))
                }
                
                onDeviceDetached = { _ ->
                    cleanup()
                    sendEvent(mapOf(
                        "event" to "device_detached",
                        "message" to "设备已断开"
                    ))
                }
                
                onPermissionGranted = { dev ->
                    Log.d(TAG, "权限已授予，打开设备")
                    openDevice(dev)
                }
                
                onPermissionDenied = { _ ->
                    sendEvent(mapOf(
                        "event" to "error",
                        "code" to "PERMISSION_DENIED",
                        "message" to "USB权限被拒绝"
                    ))
                }
                
                register(ctx)
            }
            
            // 请求权限
            if (!hidManager!!.hasPermission(device)) {
                Log.d(TAG, "请求USB权限")
                usbReceiver?.requestPermission(ctx, device)
                result.success(mapOf(
                    "success" to true,
                    "message" to "正在请求USB权限，请在弹窗中允许"
                ))
            } else {
                Log.d(TAG, "已有USB权限，直接打开设备")
                if (openDevice(device)) {
                    result.success(mapOf(
                        "success" to true,
                        "message" to "初始化成功"
                    ))
                } else {
                    result.success(mapOf(
                        "success" to false,
                        "message" to "打开设备失败"
                    ))
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "初始化失败: ${e.message}", e)
            result.error("INIT_ERROR", "初始化失败: ${e.message}", null)
        }
    }
    
    /**
     * 打开设备
     */
    private fun openDevice(device: UsbDevice): Boolean {
        val hid = hidManager ?: return false
        
        if (!hid.open(device)) {
            Log.e(TAG, "打开设备失败")
            sendEvent(mapOf(
                "event" to "error",
                "code" to "OPEN_FAILED",
                "message" to "打开设备失败"
            ))
            return false
        }
        
        // 创建卡片服务
        cardService = M1CardService(hid).apply {
            onCardDetected = { uid, cardType ->
                sendEvent(mapOf(
                    "event" to "card_detected",
                    "uid" to Protocol.formatUid(uid),
                    "cardType" to cardType
                ))
            }
            
            onAuthResult = { success, message ->
                sendEvent(mapOf(
                    "event" to "auth_result",
                    "success" to success,
                    "message" to message
                ))
            }
            
            onBlockRead = { blockData ->
                sendEvent(mapOf(
                    "event" to "block_read",
                    "data" to blockData.toList()
                ))
            }
            
            onError = { errorCode, message ->
                sendEvent(mapOf(
                    "event" to "error",
                    "code" to errorCode,
                    "message" to message
                ))
            }
        }
        
        isInitialized = true
        
        sendEvent(mapOf(
            "event" to "device_ready",
            "message" to "设备已就绪"
        ))
        
        Log.d(TAG, "✓ 设备打开成功")
        return true
    }
    
    /**
     * 获取设备信息
     */
    private fun handleGetDeviceInfo(result: MethodChannel.Result) {
        val info = hidManager?.getDeviceInfo()
        if (info != null) {
            result.success(info)
        } else {
            result.success(mapOf(
                "error" to "设备未连接"
            ))
        }
    }
    
    /**
     * 认证扇区
     */
    private fun handleAuthSector(call: MethodCall, result: MethodChannel.Result) {
        if (!isInitialized || cardService == null) {
            result.error("NOT_INITIALIZED", "读卡器未初始化", null)
            return
        }
        
        val sector = call.argument<Int>("sector")
        val key = call.argument<List<Int>>("key")
        val useKeyA = call.argument<Boolean>("keyA") ?: true
        
        if (sector == null || key == null || key.size != 6) {
            result.error("INVALID_ARGUMENT", "参数错误：sector和key(6字节)必须提供", null)
            return
        }
        
        // 转换密钥
        val keyBytes = key.map { it.toByte() }.toByteArray()
        
        // 异步执行
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val success = cardService!!.authSector(sector, keyBytes, useKeyA)
                result.success(mapOf(
                    "success" to success
                ))
            } catch (e: Exception) {
                result.error("AUTH_ERROR", "认证异常: ${e.message}", null)
            }
        }
    }
    
    /**
     * 读取块
     */
    private fun handleReadBlock(call: MethodCall, result: MethodChannel.Result) {
        if (!isInitialized || cardService == null) {
            result.error("NOT_INITIALIZED", "读卡器未初始化", null)
            return
        }
        
        val block = call.argument<Int>("block")
        if (block == null) {
            result.error("INVALID_ARGUMENT", "参数错误：block必须提供", null)
            return
        }
        
        // 异步执行
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val data = cardService!!.readBlock(block)
                if (data != null) {
                    result.success(mapOf(
                        "success" to true,
                        "data" to data.toList()
                    ))
                } else {
                    result.success(mapOf(
                        "success" to false,
                        "message" to "读取失败"
                    ))
                }
            } catch (e: Exception) {
                result.error("READ_ERROR", "读取异常: ${e.message}", null)
            }
        }
    }
    
    /**
     * 启动自动寻卡
     */
    private fun handleStartAutoPolling(result: MethodChannel.Result) {
        if (!isInitialized || cardService == null) {
            result.error("NOT_INITIALIZED", "读卡器未初始化", null)
            return
        }
        
        if (autoPollingJob?.isActive == true) {
            result.success(mapOf(
                "success" to true,
                "message" to "自动寻卡已在运行"
            ))
            return
        }
        
        autoPollingJob = cardService!!.startAutoPolling(500)
        
        result.success(mapOf(
            "success" to true,
            "message" to "自动寻卡已启动"
        ))
        
        Log.d(TAG, "✓ 自动寻卡已启动")
    }
    
    /**
     * 停止自动寻卡
     */
    private fun handleStopAutoPolling(result: MethodChannel.Result) {
        autoPollingJob?.cancel()
        autoPollingJob = null
        
        result.success(mapOf(
            "success" to true,
            "message" to "自动寻卡已停止"
        ))
        
        Log.d(TAG, "自动寻卡已停止")
    }
    
    /**
     * EventChannel: 监听开始
     */
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "EventChannel开始监听")
        eventSink = events
    }
    
    /**
     * EventChannel: 取消监听
     */
    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "EventChannel取消监听")
        eventSink = null
    }
    
    /**
     * 发送事件到Flutter
     */
    private fun sendEvent(event: Map<String, Any>) {
        val sink = eventSink
        if (sink != null) {
            CoroutineScope(Dispatchers.Main).launch {
                sink.success(event)
            }
        } else {
            Log.w(TAG, "EventSink为空，无法发送事件: ${event["event"]}")
        }
    }
    
    /**
     * 清理资源
     */
    private fun cleanup() {
        Log.d(TAG, "清理资源")
        
        autoPollingJob?.cancel()
        autoPollingJob = null
        
        cardService?.clearCard()
        cardService = null
        
        hidManager?.close()
        hidManager = null
        
        context?.let { ctx ->
            usbReceiver?.unregister(ctx)
        }
        usbReceiver = null
        
        currentDevice = null
        isInitialized = false
    }
}
