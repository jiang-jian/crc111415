package com.holox.ailand_pos

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.nio.charset.Charset

/**
 * 外接USB打印机插件
 * 用于检测和管理通过USB连接的外接打印机设备
 * 完全独立于内置Sunmi打印机功能
 */
class ExternalPrinterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var usbManager: UsbManager? = null

    companion object {
        private const val TAG = "ExternalPrinter"
        private const val CHANNEL_NAME = "com.holox.ailand_pos/external_printer"
        private const val ACTION_USB_PERMISSION = "com.holox.ailand_pos.USB_PERMISSION"
        
        // USB打印机类代码
        // Class 7 = Printer
        private const val USB_CLASS_PRINTER = 7
    }

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                ACTION_USB_PERMISSION -> {
                    synchronized(this) {
                        val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                        }

                        if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                            device?.let {
                                Log.d(TAG, "USB permission granted for device: ${it.deviceName}")
                            }
                        } else {
                            Log.d(TAG, "USB permission denied for device: ${device?.deviceName}")
                        }
                    }
                }
                UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                    Log.d(TAG, "USB device attached")
                    channel.invokeMethod("onUsbDeviceAttached", null)
                }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    Log.d(TAG, "USB device detached")
                    channel.invokeMethod("onUsbDeviceDetached", null)
                }
            }
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        usbManager = context?.getSystemService(Context.USB_SERVICE) as? UsbManager

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)

        // 注册USB设备广播接收器
        val filter = IntentFilter().apply {
            addAction(ACTION_USB_PERMISSION)
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context?.registerReceiver(usbReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context?.registerReceiver(usbReceiver, filter)
        }

        Log.d(TAG, "ExternalPrinterPlugin attached")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        try {
            context?.unregisterReceiver(usbReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receiver: ${e.message}")
        }
        context = null
        usbManager = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "scanUsbPrinters" -> scanUsbPrinters(result)
            "hasPermission" -> hasPermission(call, result)
            "requestPermission" -> requestPermission(call, result)
            "testPrint" -> testPrint(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * 扫描USB打印机设备
     */
    private fun scanUsbPrinters(result: Result) {
        try {
            val deviceList = usbManager?.deviceList ?: emptyMap()
            Log.d(TAG, "Scanning USB devices, found: ${deviceList.size}")

            val printers = deviceList.values
                .filter { isPrinterDevice(it) }
                .map { device ->
                    hashMapOf(
                        "deviceId" to device.deviceId.toString(),
                        "deviceName" to device.deviceName,
                        "manufacturer" to (device.manufacturerName ?: "Unknown"),
                        "productName" to (device.productName ?: "Unknown"),
                        "vendorId" to device.vendorId,
                        "productId" to device.productId,
                        "isConnected" to true,
                        "serialNumber" to device.serialNumber
                    )
                }

            Log.d(TAG, "Found ${printers.size} printer devices")
            result.success(printers)
        } catch (e: Exception) {
            Log.e(TAG, "Error scanning USB devices: ${e.message}", e)
            result.error("SCAN_ERROR", "Failed to scan USB devices: ${e.message}", null)
        }
    }

    /**
     * 判断是否为打印机设备
     */
    private fun isPrinterDevice(device: UsbDevice): Boolean {
        // 方法1: 检查USB设备类
        if (device.deviceClass == USB_CLASS_PRINTER) {
            Log.d(TAG, "Device ${device.deviceName} is a printer (by device class)")
            return true
        }

        // 方法2: 检查接口类
        for (i in 0 until device.interfaceCount) {
            val usbInterface = device.getInterface(i)
            if (usbInterface.interfaceClass == USB_CLASS_PRINTER) {
                Log.d(TAG, "Device ${device.deviceName} is a printer (by interface class)")
                return true
            }
        }

        // 方法3: 检查常见打印机厂商ID
        // 可以根据实际使用的打印机品牌添加更多厂商ID
        val knownPrinterVendors = listOf(
            0x04b8, // Epson
            0x04e8, // Samsung
            0x03f0, // HP
            0x04a9, // Canon
            0x067b, // Prolific (常用于热敏打印机)
            0x0416, // 芯烨 (Xprinter)
            0x0519, // 佳博 (Gprinter)
        )

        if (device.vendorId in knownPrinterVendors) {
            Log.d(TAG, "Device ${device.deviceName} is likely a printer (by vendor ID)")
            return true
        }

        return false
    }

    /**
     * 检查USB设备权限（不请求）
     */
    private fun hasPermission(call: MethodCall, result: Result) {
        try {
            val deviceId = call.argument<String>("deviceId")
            if (deviceId == null) {
                result.error("INVALID_ARGUMENT", "Device ID is required", null)
                return
            }

            val device = findDeviceById(deviceId)
            if (device == null) {
                result.error("DEVICE_NOT_FOUND", "Device not found: $deviceId", null)
                return
            }

            val hasPermission = usbManager?.hasPermission(device) == true
            Log.d(TAG, "Check permission for device ${device.deviceName}: $hasPermission")
            result.success(hasPermission)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking permission: ${e.message}", e)
            result.error("PERMISSION_CHECK_ERROR", "Failed to check permission: ${e.message}", null)
        }
    }

    /**
     * 请求USB设备权限
     */
    private fun requestPermission(call: MethodCall, result: Result) {
        try {
            val deviceId = call.argument<String>("deviceId")
            if (deviceId == null) {
                result.error("INVALID_ARGUMENT", "Device ID is required", null)
                return
            }

            val device = findDeviceById(deviceId)
            if (device == null) {
                result.error("DEVICE_NOT_FOUND", "Device not found: $deviceId", null)
                return
            }

            if (usbManager?.hasPermission(device) == true) {
                Log.d(TAG, "Already has permission for device: ${device.deviceName}")
                result.success(true)
                return
            }

            val permissionIntent = PendingIntent.getBroadcast(
                context,
                0,
                Intent(ACTION_USB_PERMISSION),
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.FLAG_MUTABLE
                } else {
                    0
                }
            )

            usbManager?.requestPermission(device, permissionIntent)
            Log.d(TAG, "Requesting permission for device: ${device.deviceName}")
            
            // 注意：权限结果通过广播接收器处理
            // 这里先返回true，实际权限状态在广播中处理
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting permission: ${e.message}", e)
            result.error("PERMISSION_ERROR", "Failed to request permission: ${e.message}", null)
        }
    }

    /**
     * 测试打印
     */
    private fun testPrint(call: MethodCall, result: Result) {
        try {
            val deviceId = call.argument<String>("deviceId")
            val testText = call.argument<String>("testText") ?: "Test Print"

            if (deviceId == null) {
                result.error("INVALID_ARGUMENT", "Device ID is required", null)
                return
            }

            val device = findDeviceById(deviceId)
            if (device == null) {
                result.error("DEVICE_NOT_FOUND", "Device not found: $deviceId", null)
                return
            }

            if (usbManager?.hasPermission(device) != true) {
                result.error("NO_PERMISSION", "No permission for device", null)
                return
            }

            // 尝试打印
            val printSuccess = printToDevice(device, testText)

            if (printSuccess) {
                result.success(
                    hashMapOf(
                        "success" to true,
                        "message" to "打印测试成功"
                    )
                )
            } else {
                result.success(
                    hashMapOf(
                        "success" to false,
                        "message" to "打印失败，请检查打印机状态"
                    )
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error during test print: ${e.message}", e)
            result.error("PRINT_ERROR", "Print failed: ${e.message}", null)
        }
    }

    /**
     * 根据设备ID查找USB设备
     */
    private fun findDeviceById(deviceId: String): UsbDevice? {
        return usbManager?.deviceList?.values?.find {
            it.deviceId.toString() == deviceId
        }
    }

    /**
     * 向USB设备发送打印数据
     * 使用ESC/POS命令集（热敏打印机通用标准）
     */
    private fun printToDevice(device: UsbDevice, text: String): Boolean {
        var connection: android.hardware.usb.UsbDeviceConnection? = null
        try {
            connection = usbManager?.openDevice(device)
            if (connection == null) {
                Log.e(TAG, "Failed to open device connection")
                return false
            }

            // 查找打印机端点
            val usbInterface = device.getInterface(0)
            connection.claimInterface(usbInterface, true)

            var endpoint: android.hardware.usb.UsbEndpoint? = null
            for (i in 0 until usbInterface.endpointCount) {
                val ep = usbInterface.getEndpoint(i)
                if (ep.direction == android.hardware.usb.UsbConstants.USB_DIR_OUT) {
                    endpoint = ep
                    break
                }
            }

            if (endpoint == null) {
                Log.e(TAG, "No OUT endpoint found")
                return false
            }

            // 构建ESC/POS打印命令
            val commands = buildEscPosPrintCommand(text)

            // 发送数据到打印机
            val bytesWritten = connection.bulkTransfer(
                endpoint,
                commands,
                commands.size,
                5000 // 5秒超时
            )

            Log.d(TAG, "Bytes written: $bytesWritten / ${commands.size}")
            return bytesWritten > 0
        } catch (e: IOException) {
            Log.e(TAG, "IO Error during print: ${e.message}", e)
            return false
        } catch (e: Exception) {
            Log.e(TAG, "Error during print: ${e.message}", e)
            return false
        } finally {
            connection?.close()
        }
    }

    /**
     * 构建ESC/POS打印命令
     * ESC/POS是热敏打印机的通用命令标准
     * 支持样式标记解析：[bold], [center], [left], [right], [size=N], [underline]
     */
    private fun buildEscPosPrintCommand(text: String): ByteArray {
        val commands = mutableListOf<Byte>()

        // ESC @ - 初始化打印机
        commands.addAll(listOf<Byte>(0x1B.toByte(), 0x40.toByte()))

        // 解析并添加带样式的文本内容
        parseAndAddStyledText(text, commands)

        // LF - 换行
        commands.add(0x0A)
        commands.add(0x0A)

        // GS V 66 0 - 切纸（部分切纸）
        commands.addAll(listOf<Byte>(0x1D.toByte(), 0x56.toByte(), 0x42.toByte(), 0x00.toByte()))

        return commands.toByteArray()
    }

    /**
     * 解析样式标记并转换为ESC/POS指令
     * 支持多种标记格式以匹配预览效果：
     * - XML风格: [bold], [center], [size=2]
     * - Markdown风格: **粗体**, __下划线__, ~~删除线~~
     * - HTML风格: <xl>, <large>, <small>
     * - 分隔线: ===, ---
     */
    private fun parseAndAddStyledText(text: String, commands: MutableList<Byte>) {
        var currentPos = 0
        val textLength = text.length
        
        // 使用 GB18030 编码（兼容GBK，支持所有中文字符）
        val charset = Charset.forName("GB18030")
        
        // 样式状态追踪
        var isBold = false
        var isUnderline = false
        var alignment = 0 // 0=left, 1=center, 2=right
        var fontSize = 0 // 0=normal, 1=large(1.3x), 2=xl(1.6x)

        while (currentPos < textLength) {
            var matched = false
            var advancePos = currentPos

            // 1. 检查 Markdown 粗体 **text**
            if (currentPos < textLength - 2 && text.substring(currentPos).startsWith("**")) {
                val endPos = text.indexOf("**", currentPos + 2)
                if (endPos != -1) {
                    val content = text.substring(currentPos + 2, endPos)
                    commands.addAll(listOf<Byte>(0x1B.toByte(), 0x45.toByte(), 0x01.toByte())) // 加粗开启
                    commands.addAll(content.toByteArray(charset).toList())
                    commands.addAll(listOf<Byte>(0x1B.toByte(), 0x45.toByte(), 0x00.toByte())) // 加粗关闭
                    advancePos = endPos + 2
                    matched = true
                }
            }

            // 2. 检查 Markdown 斜体 *text* (打印机不支持斜体，按普通文本处理)
            if (!matched && currentPos < textLength - 1 && text[currentPos] == '*' && text[currentPos + 1] != '*') {
                val endPos = text.indexOf('*', currentPos + 1)
                if (endPos != -1) {
                    val content = text.substring(currentPos + 1, endPos)
                    commands.addAll(content.toByteArray(charset).toList())
                    advancePos = endPos + 1
                    matched = true
                }
            }

            // 3. 检查 Markdown 下划线 __text__
            if (!matched && currentPos < textLength - 2 && text.substring(currentPos).startsWith("__")) {
                val endPos = text.indexOf("__", currentPos + 2)
                if (endPos != -1) {
                    val content = text.substring(currentPos + 2, endPos)
                    commands.addAll(listOf<Byte>(0x1B.toByte(), 0x2D.toByte(), 0x01.toByte())) // 下划线开启
                    commands.addAll(content.toByteArray(charset).toList())
                    commands.addAll(listOf<Byte>(0x1B.toByte(), 0x2D.toByte(), 0x00.toByte())) // 下划线关闭
                    advancePos = endPos + 2
                    matched = true
                }
            }

            // 4. 检查 Markdown 删除线 ~~text~~ (打印机显示为普通文本)
            if (!matched && currentPos < textLength - 2 && text.substring(currentPos).startsWith("~~")) {
                val endPos = text.indexOf("~~", currentPos + 2)
                if (endPos != -1) {
                    val content = text.substring(currentPos + 2, endPos)
                    commands.addAll(content.toByteArray(charset).toList())
                    advancePos = endPos + 2
                    matched = true
                }
            }

            // 5. 检查 HTML 超大字号 <xl>text</xl>
            if (!matched && text.substring(currentPos).startsWith("<xl>")) {
                val endPos = text.indexOf("</xl>", currentPos)
                if (endPos != -1) {
                    val content = text.substring(currentPos + 4, endPos)
                    commands.addAll(listOf<Byte>(0x1D.toByte(), 0x21.toByte(), 0x11.toByte())) // 2倍字号 + 加粗
                    commands.addAll(listOf<Byte>(0x1B.toByte(), 0x45.toByte(), 0x01.toByte()))
                    commands.addAll(content.toByteArray(charset).toList())
                    commands.addAll(listOf(0x1B, 0x45, 0x00))
                    commands.addAll(listOf(0x1D, 0x21, 0x00.toByte()))
                    advancePos = endPos + 5
                    matched = true
                }
            }

            // 6. 检查 HTML 大字号 <large>text</large>
            if (!matched && text.substring(currentPos).startsWith("<large>")) {
                val endPos = text.indexOf("</large>", currentPos)
                if (endPos != -1) {
                    val content = text.substring(currentPos + 7, endPos)
                    commands.addAll(listOf<Byte>(0x1D.toByte(), 0x21.toByte(), 0x10.toByte())) // 宽度2倍
                    commands.addAll(content.toByteArray(charset).toList())
                    commands.addAll(listOf<Byte>(0x1D.toByte(), 0x21.toByte(), 0x00.toByte()))
                    advancePos = endPos + 8
                    matched = true
                }
            }

            // 7. 检查 HTML 小字号 <small>text</small> (打印机最小字号限制，按正常处理)
            if (!matched && text.substring(currentPos).startsWith("<small>")) {
                val endPos = text.indexOf("</small>", currentPos)
                if (endPos != -1) {
                    val content = text.substring(currentPos + 7, endPos)
                    commands.addAll(content.toByteArray(charset).toList())
                    advancePos = endPos + 8
                    matched = true
                }
            }

            // 8. 检查分隔线 === 或 ---（支持被标记包裹的情况）
            if (!matched && currentPos < textLength - 2) {
                // 检查是否是连续的3个 = 或 -
                val char = text[currentPos]
                if ((char == '=' || char == '-') && 
                    currentPos + 2 < textLength &&
                    text[currentPos + 1] == char && 
                    text[currentPos + 2] == char) {
                    
                    // 确认这是一个分隔线（前后是换行或标记结束）
                    val isLineStart = currentPos == 0 || text[currentPos - 1] == '\n' || text[currentPos - 1] == ']' || text[currentPos - 1] == '>'
                    val nextPos = currentPos + 3
                    val isLineEnd = nextPos >= textLength || text[nextPos] == '\n' || text[nextPos] == '[' || text[nextPos] == '<'
                    
                    if (isLineStart && isLineEnd) {
                        // 打印分隔线（32个字符宽度的横线）
                        val separator = if (char == '=') "=" else "-"
                        val separatorLine = separator.repeat(32)
                        commands.addAll(separatorLine.toByteArray(charset).toList())
                        commands.add(0x0A) // 换行
                        advancePos = nextPos
                        matched = true
                    }
                }
            }

            // 9. 检查换行标记 <br>
            if (!matched && text.substring(currentPos).startsWith("<br>")) {
                commands.add(0x0A)
                advancePos = currentPos + 4
                matched = true
            }

            // 10. 检查 XML 风格标记 [tag]
            if (!matched && text[currentPos] == '[') {
                val tagEnd = text.indexOf(']', currentPos)
                if (tagEnd != -1) {
                    val tag = text.substring(currentPos + 1, tagEnd)
                    var handled = false

                    when {
                        tag == "bold" -> {
                            commands.addAll(listOf<Byte>(0x1B.toByte(), 0x45.toByte(), 0x01.toByte()))
                            handled = true
                        }
                        tag == "/bold" -> {
                            commands.addAll(listOf<Byte>(0x1B.toByte(), 0x45.toByte(), 0x00.toByte()))
                            handled = true
                        }
                        tag == "underline" -> {
                            commands.addAll(listOf<Byte>(0x1B.toByte(), 0x2D.toByte(), 0x01.toByte()))
                            handled = true
                        }
                        tag == "/underline" -> {
                            commands.addAll(listOf<Byte>(0x1B.toByte(), 0x2D.toByte(), 0x00.toByte()))
                            handled = true
                        }
                        tag == "center" -> {
                            commands.addAll(listOf<Byte>(0x1B.toByte(), 0x61.toByte(), 0x01.toByte()))
                            handled = true
                        }
                        tag == "left" -> {
                            commands.addAll(listOf<Byte>(0x1B.toByte(), 0x61.toByte(), 0x00.toByte()))
                            handled = true
                        }
                        tag == "right" -> {
                            commands.addAll(listOf<Byte>(0x1B.toByte(), 0x61.toByte(), 0x02.toByte()))
                            handled = true
                        }
                        tag == "/center" || tag == "/left" || tag == "/right" -> {
                            // 不重置对齐（ESC/POS对齐是行级别的，保持到下一个对齐标签）
                            handled = true
                        }
                        tag.startsWith("size=") -> {
                            val sizeStr = tag.substring(5)
                            val size = sizeStr.toIntOrNull() ?: 1
                            val sizeValue = when {
                                size >= 3 -> 0x22.toByte()
                                size == 2 -> 0x11.toByte()
                                else -> 0x00.toByte()
                            }
                            commands.addAll(listOf<Byte>(0x1D.toByte(), 0x21.toByte(), sizeValue))
                            handled = true
                        }
                        tag == "/size" -> {
                            // 重置字号为正常大小（不添加换行，由模板控制）
                            commands.addAll(listOf<Byte>(0x1D.toByte(), 0x21.toByte(), 0x00.toByte()))
                            handled = true
                        }
                    }

                    if (handled) {
                        advancePos = tagEnd + 1
                        matched = true
                    }
                }
            }

            // 如果没有匹配任何标记，添加当前字符（使用GB18030编码）
            if (!matched) {
                val char = text[currentPos]
                // 处理换行符：直接转换为打印机换行指令
                if (char == '\n') {
                    commands.add(0x0A)
                } else {
                    // 普通字符按编码添加
                    commands.addAll(char.toString().toByteArray(charset).toList())
                }
                advancePos = currentPos + 1
            }

            currentPos = advancePos
        }

        // 重置字符级样式到默认状态（不重置对齐，因为对齐是行级样式）
        commands.addAll(listOf<Byte>(0x1B.toByte(), 0x45.toByte(), 0x00.toByte())) // 取消加粗
        commands.addAll(listOf<Byte>(0x1B.toByte(), 0x2D.toByte(), 0x00.toByte())) // 取消下划线
        commands.addAll(listOf<Byte>(0x1D.toByte(), 0x21.toByte(), 0x00.toByte())) // 正常字号
    }
}

