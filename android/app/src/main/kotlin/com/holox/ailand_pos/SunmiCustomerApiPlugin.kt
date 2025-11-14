package com.holox.ailand_pos

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Sunmi Customer API Plugin for Flutter
 * 使用反射调用 Sunmi Customer API SDK
 * 
 * 参考官方文档：
 * TMSApi sTmsApi = new TMSApi();
 * sTmsApi.setLoggable(true);
 * sTmsApi.connect(this, new TMSServiceConnection() {...});
 */
class SunmiCustomerApiPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    
    // 对应官方文档的 sTmsApi，作为成员变量保存
    private var sTmsApi: Any? = null
    private var isConnected = false
    private val handler = Handler(Looper.getMainLooper())

    companion object {
        private const val TAG = "SunmiCustomerApi"
        private const val CHANNEL_NAME = "com.holox.ailand_pos/sunmi_customer_api"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        Log.d(TAG, "Plugin attached")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        disconnect()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "isConnected" -> result.success(isConnected)
            "checkServiceInstalled" -> checkServiceInstalled(result)
            "enableMobileNetwork" -> enableMobileNetwork(call, result)
            "disableMobileNetwork" -> disableMobileNetwork(call, result)
            "getDeviceModel" -> getDeviceModel(result)
            "getDeviceSerialNumber" -> getDeviceSerialNumber(result)
            "getDeviceInfo" -> getDeviceInfo(result)
            else -> result.notImplemented()
        }
    }
    
    /**
     * 检查 SunmiCustomerService 是否已安装
     */
    private fun checkServiceInstalled(result: Result) {
        try {
            val packageManager = context.packageManager
            packageManager.getPackageInfo("com.sunmi.tmservice", 0)
            Log.d(TAG, "✓ SunmiCustomerService is installed")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "✗ SunmiCustomerService is NOT installed: ${e.message}")
            result.success(false)
        }
    }

    /**
     * 初始化并连接服务（对应官方文档的 connectTmsService）
     * 
     * 官方示例：
     * TMSApi sTmsApi = new TMSApi();
     * sTmsApi.setLoggable(true);
     * sTmsApi.connect(this, new TMSServiceConnection() {
     *     @Override
     *     public void onServiceConnected() {
     *         // tms service is connected
     *     }
     *     @Override
     *     public void onServiceDisconnected() {
     *         // tms service is disconnected
     *     }
     * });
     */
    private fun initialize(result: Result) {
        Log.d(TAG, "=== Initialize called ===")
        Log.d(TAG, "Current state: sTmsApi=${sTmsApi != null}, isConnected=$isConnected")
        
        // 如果已经连接，直接返回
        if (isConnected && sTmsApi != null) {
            Log.d(TAG, "✓ Already connected, returning true")
            result.success(true)
            return
        }
        
        // 如果正在连接中，等待最多3秒
        if (sTmsApi != null && !isConnected) {
            Log.d(TAG, "⏳ Connection in progress, waiting up to 3 seconds...")
            waitForConnection(result, 0)
            return
        }
        
        // 开始新的连接（严格按照官方文档）
        try {
            Log.d(TAG, "🔄 Starting new connection (following official docs)...")
            
            // 1. TMSApi sTmsApi = new TMSApi();
            val tmsApiClass = Class.forName("com.sunmi.tms.api.TMSApi")
            sTmsApi = tmsApiClass.newInstance()
            Log.d(TAG, "✓ Step 1: TMSApi instance created: $sTmsApi")
            
            // 2. sTmsApi.setLoggable(true);
            val setLoggableMethod = tmsApiClass.getMethod("setLoggable", Boolean::class.java)
            setLoggableMethod.invoke(sTmsApi, true)
            Log.d(TAG, "✓ Step 2: setLoggable(true) called")
            
            // 3. 创建 TMSServiceConnection 回调
            val connectionClass = Class.forName("com.sunmi.tms.api.TMSServiceConnection")
            val connectionCallback = java.lang.reflect.Proxy.newProxyInstance(
                connectionClass.classLoader,
                arrayOf(connectionClass)
            ) { _, method, _ ->
                when (method.name) {
                    "onServiceConnected" -> {
                        isConnected = true
                        Log.d(TAG, "✓✓✓ onServiceConnected() called! isConnected = $isConnected")
                    }
                    "onServiceDisconnected" -> {
                        isConnected = false
                        Log.d(TAG, "✗✗✗ onServiceDisconnected() called! isConnected = $isConnected")
                    }
                }
                null
            }
            Log.d(TAG, "✓ Step 3: TMSServiceConnection callback created")
            
            // 4. sTmsApi.connect(this, callback);
            // 注意：官方文档中第一个参数是 this (Context)
            val connectMethod = tmsApiClass.getMethod("connect", Context::class.java, connectionClass)
            connectMethod.invoke(sTmsApi, context, connectionCallback)
            Log.d(TAG, "✓ Step 4: connect(context, callback) called")
            Log.d(TAG, "Waiting for onServiceConnected callback...")
            
            // 等待连接完成（异步回调）
            waitForConnection(result, 0)
            
        } catch (e: Exception) {
            Log.e(TAG, "✗ Initialize failed: ${e.message}", e)
            e.printStackTrace()
            sTmsApi = null
            isConnected = false
            result.success(false)
        }
    }
    
    /**
     * 等待连接完成（最多3秒，每500ms检查一次）
     * 
     * 注意：TMSServiceConnection 接口只有两个回调方法：
     * - onServiceConnected() - 连接成功时调用
     * - onServiceDisconnected() - 连接断开时调用
     * 
     * SDK 没有提供连接失败的回调，所以我们需要使用超时机制。
     * 如果超时后仍未连接，可能的原因：
     * 1. 设备上未安装 SunmiCustomerService 应用
     * 2. 不是商米设备或模拟器不支持
     * 3. 权限问题（需要在 AndroidManifest.xml 中添加 queries）
     */
    private fun waitForConnection(result: Result, attempt: Int) {
        if (isConnected) {
            Log.d(TAG, "✓ Connection successful after ${attempt * 500}ms")
            result.success(true)
            return
        }
        
        if (attempt >= 6) { // 3秒 = 6 * 500ms
            Log.e(TAG, "✗ Connection timeout after 3 seconds")
            Log.e(TAG, "Possible reasons:")
            Log.e(TAG, "  1. SunmiCustomerService app not installed on device")
            Log.e(TAG, "  2. Not a Sunmi device or emulator doesn't support it")
            Log.e(TAG, "  3. Missing <queries> in AndroidManifest.xml")
            Log.e(TAG, "  4. Service binding failed silently")
            result.success(false)
            return
        }
        
        Log.d(TAG, "Waiting... attempt ${attempt + 1}/6, isConnected = $isConnected")
        handler.postDelayed({
            waitForConnection(result, attempt + 1)
        }, 500)
    }

    /**
     * 断开连接
     */
    private fun disconnect() {
        try {
            sTmsApi?.let {
                val disconnectMethod = it.javaClass.getMethod("disconnect")
                disconnectMethod.invoke(it)
                Log.d(TAG, "Disconnected")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Disconnect failed: ${e.message}")
        } finally {
            sTmsApi = null
            isConnected = false
        }
    }

    /**
     * 检查连接状态
     */
    private fun checkConnection(result: Result): Boolean {
        if (!isConnected || sTmsApi == null) {
            result.error("NOT_CONNECTED", "Service not connected", null)
            return false
        }
        return true
    }

    /**
     * 启用移动网络
     */
    private fun enableMobileNetwork(call: MethodCall, result: Result) {
        if (!checkConnection(result)) return
        
        try {
            val slotIndex = call.argument<Int>("slotIndex") ?: 0
            val networkManagerMethod = sTmsApi!!.javaClass.getMethod("getNetworkManager")
            val networkManager = networkManagerMethod.invoke(sTmsApi)
            val enableMethod = networkManager.javaClass.getMethod(
                "enableMobileNetwork", Int::class.java, Boolean::class.java
            )
            enableMethod.invoke(networkManager, slotIndex, true)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Enable network failed: ${e.message}")
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * 禁用移动网络
     */
    private fun disableMobileNetwork(call: MethodCall, result: Result) {
        if (!checkConnection(result)) return
        
        try {
            val slotIndex = call.argument<Int>("slotIndex") ?: 0
            val networkManagerMethod = sTmsApi!!.javaClass.getMethod("getNetworkManager")
            val networkManager = networkManagerMethod.invoke(sTmsApi)
            val enableMethod = networkManager.javaClass.getMethod(
                "enableMobileNetwork", Int::class.java, Boolean::class.java
            )
            enableMethod.invoke(networkManager, slotIndex, false)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Disable network failed: ${e.message}")
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * 获取设备型号
     */
    private fun getDeviceModel(result: Result) {
        if (!checkConnection(result)) return
        
        try {
            val deviceInfoMethod = sTmsApi!!.javaClass.getMethod("getDeviceInfo")
            val deviceInfo = deviceInfoMethod.invoke(sTmsApi)
            val getModelMethod = deviceInfo.javaClass.getMethod("getModel")
            val model = getModelMethod.invoke(deviceInfo) as? String
            result.success(model)
        } catch (e: Exception) {
            Log.e(TAG, "Get model failed: ${e.message}")
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * 获取设备序列号
     */
    private fun getDeviceSerialNumber(result: Result) {
        if (!checkConnection(result)) return
        
        try {
            val deviceInfoMethod = sTmsApi!!.javaClass.getMethod("getDeviceInfo")
            val deviceInfo = deviceInfoMethod.invoke(sTmsApi)
            val getSerialMethod = deviceInfo.javaClass.getMethod("getSerialNumber")
            val serial = getSerialMethod.invoke(deviceInfo) as? String
            result.success(serial)
        } catch (e: Exception) {
            Log.e(TAG, "Get serial failed: ${e.message}")
            result.error("ERROR", e.message, null)
        }
    }

    /**
     * 获取设备完整信息
     */
    private fun getDeviceInfo(result: Result) {
        if (!checkConnection(result)) return
        
        try {
            val deviceInfoMethod = sTmsApi!!.javaClass.getMethod("getDeviceInfo")
            val deviceInfo = deviceInfoMethod.invoke(sTmsApi)
            
            val info = mutableMapOf<String, String?>()
            
            // 安全获取各个属性
            listOf(
                "model" to "getModel",
                "serialNumber" to "getSerialNumber",
                "manufacturer" to "getManufacturer",
                "brand" to "getBrand",
                "androidVersion" to "getAndroidVersion",
                "sdkVersion" to "getSdkVersion"
            ).forEach { (key, methodName) ->
                try {
                    val method = deviceInfo.javaClass.getMethod(methodName)
                    info[key] = method.invoke(deviceInfo) as? String
                } catch (e: Exception) {
                    Log.w(TAG, "Failed to get $key: ${e.message}")
                    info[key] = null
                }
            }
            
            result.success(info)
        } catch (e: Exception) {
            Log.e(TAG, "Get device info failed: ${e.message}")
            result.error("ERROR", e.message, null)
        }
    }
}
