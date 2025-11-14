import 'dart:io';
import 'package:ailand_pos/data/services/nfc_service.dart';
import 'package:ailand_pos/data/services/sunmi_printer_service.dart';
import 'package:ailand_pos/data/services/external_printer_service.dart';
import 'package:ailand_pos/data/services/receipt_template_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'app/routes/router_config.dart';
import 'app/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'core/controllers/locale_controller.dart';
import 'core/widgets/app_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 只在 macOS 和 Windows 平台上使用 window_manager
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
    await windowManager.ensureInitialized();

    // 设置窗口默认大小和约束
    const windowOptions = WindowOptions(
      size: Size(1920, 1080),
      minimumSize: Size(960, 540), // 最小尺寸为默认尺寸的一半,保持16:9比例
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      // 设置窗口宽高比为 16:9
      await windowManager.setAspectRatio(16 / 9);
    });
  }

  await initServices();
  runApp(const MyApp());
}

Future<void> initServices() async {
  await Get.putAsync(() => StorageService().init());
  // 预先初始化 NfcService（全局单例）
  await Get.putAsync(() => NfcService().init());
  // 预先初始化商米打印机服务（全局单例）
  await Get.putAsync(() => SunmiPrinterService().init());
  // 预先初始化外接打印机服务（全局单例）
  await Get.putAsync(() => ExternalPrinterService().init());
  // 预先初始化小票模板服务（全局单例）
  await Get.putAsync(() => ReceiptTemplateService().init());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter();
    // 使用条件创建,避免热更新时重复创建导致 GlobalKey 冲突
    if (!Get.isRegistered<LocaleController>()) {
      Get.put(LocaleController());
    }
    final localeController = Get.find<LocaleController>();

    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(
          () => MaterialApp.router(
            title: 'Ailand POS',
            theme: AppTheme.materialTheme,
            debugShowCheckedModeBanner: false,
            locale: localeController.locale.value,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', 'US'), Locale('zh', 'CN')],
            routerConfig: router,
            builder: (context, child) {
              // 多层 Overlay 结构，确保层级正确
              // 从下到上：应用内容 -> Dialog -> Loading -> Toast
              return Overlay(
                key: AppOverlay.dialogOverlayKey,
                initialEntries: [
                  OverlayEntry(
                    builder: (context) => Overlay(
                      key: AppOverlay.loadingOverlayKey,
                      initialEntries: [
                        OverlayEntry(
                          builder: (context) => Overlay(
                            key: AppOverlay.toastOverlayKey,
                            initialEntries: [
                              OverlayEntry(
                                builder: (context) =>
                                    child ?? const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
