package com.holox.ailand_pos.mingtech

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import android.util.Log

/**
 * USB设备插拔与权限监听器
 */
class UsbReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "UsbReceiver"
        const val ACTION_USB_PERMISSION = "com.holox.ailand_pos.mingtech.USB_PERMISSION"
    }
    
    // 回调接口
    var onDeviceAttached: ((UsbDevice) -> Unit)? = null
    var onDeviceDetached: ((UsbDevice) -> Unit)? = null
    var onPermissionGranted: ((UsbDevice) -> Unit)? = null
    var onPermissionDenied: ((UsbDevice) -> Unit)? = null
    
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        
        Log.d(TAG, "收到广播: $action")
        
        when (action) {
            UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                handleDeviceAttached(intent)
            }
            
            UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                handleDeviceDetached(intent)
            }
            
            ACTION_USB_PERMISSION -> {
                handlePermissionResponse(intent)
            }
        }
    }
    
    /**
     * 处理设备插入事件
     */
    private fun handleDeviceAttached(intent: Intent) {
        val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
        }
        
        if (device == null) {
            Log.w(TAG, "设备插入事件，但未获取到设备对象")
            return
        }
        
        // 检查是否是明泰读卡器
        if (device.vendorId == Protocol.VENDOR_ID && device.productId == Protocol.PRODUCT_ID) {
            Log.d(TAG, "明泰读卡器已插入: ${device.deviceName}")
            Log.d(TAG, "  VID: 0x${device.vendorId.toString(16)}")
            Log.d(TAG, "  PID: 0x${device.productId.toString(16)}")
            onDeviceAttached?.invoke(device)
        } else {
            Log.d(TAG, "非明泰读卡器设备: VID=0x${device.vendorId.toString(16)}, PID=0x${device.productId.toString(16)}")
        }
    }
    
    /**
     * 处理设备拔出事件
     */
    private fun handleDeviceDetached(intent: Intent) {
        val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
        }
        
        if (device == null) {
            Log.w(TAG, "设备拔出事件，但未获取到设备对象")
            return
        }
        
        // 检查是否是明泰读卡器
        if (device.vendorId == Protocol.VENDOR_ID && device.productId == Protocol.PRODUCT_ID) {
            Log.d(TAG, "明泰读卡器已拔出: ${device.deviceName}")
            onDeviceDetached?.invoke(device)
        }
    }
    
    /**
     * 处理权限响应
     */
    private fun handlePermissionResponse(intent: Intent) {
        val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
        }
        
        if (device == null) {
            Log.w(TAG, "权限响应，但未获取到设备对象")
            return
        }
        
        val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
        
        if (granted) {
            Log.d(TAG, "✓ USB权限已授予: ${device.deviceName}")
            onPermissionGranted?.invoke(device)
        } else {
            Log.d(TAG, "✗ USB权限被拒绝: ${device.deviceName}")
            onPermissionDenied?.invoke(device)
        }
    }
    
    /**
     * 注册广播接收器
     */
    fun register(context: Context) {
        val filter = IntentFilter().apply {
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
            addAction(ACTION_USB_PERMISSION)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(this, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(this, filter)
        }
        
        Log.d(TAG, "USB接收器已注册")
    }
    
    /**
     * 注销广播接收器
     */
    fun unregister(context: Context) {
        try {
            context.unregisterReceiver(this)
            Log.d(TAG, "USB接收器已注销")
        } catch (e: Exception) {
            Log.e(TAG, "注销USB接收器失败: ${e.message}")
        }
    }
    
    /**
     * 请求USB设备权限
     */
    fun requestPermission(context: Context, device: UsbDevice) {
        val usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        
        if (usbManager.hasPermission(device)) {
            Log.d(TAG, "设备已有权限: ${device.deviceName}")
            onPermissionGranted?.invoke(device)
            return
        }
        
        Log.d(TAG, "请求USB权限: ${device.deviceName}")
        
        val permissionIntent = PendingIntent.getBroadcast(
            context,
            0,
            Intent(ACTION_USB_PERMISSION),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )
        
        usbManager.requestPermission(device, permissionIntent)
    }
}
