package com.holox.ailand_pos

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Bundle
import android.view.WindowManager

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 设置窗口为全屏模式（隐藏状态栏和导航栏）
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 注册 Sunmi Customer API Plugin（内置打印机）
        flutterEngine.plugins.add(SunmiCustomerApiPlugin())
        
        // 注册 External Printer Plugin（外接USB打印机）
        flutterEngine.plugins.add(ExternalPrinterPlugin())
        
        // 注册 External Card Reader Plugin（外接USB读卡器）
        flutterEngine.plugins.add(ExternalCardReaderPlugin())
    }
}
