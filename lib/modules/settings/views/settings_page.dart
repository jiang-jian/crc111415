import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/widgets/common_menu.dart';
import '../../../core/widgets/layouts/menu_layout_page.dart';
import '../../../modules/network_check/widgets/network_check_widget.dart';
import '../../network_check/controllers/network_check_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/version_check_controller.dart';
import 'version_check_view.dart';
import 'change_password_view.dart';
import 'placeholder_view.dart';
import 'external_card_reader_view.dart';
import 'external_printer_view.dart';
import 'qr_scanner_config_view.dart';
import 'card_registration_view.dart';
import 'game_card_management_view.dart';
import 'receipt_settings_view.dart';
import 'receipt_config_page.dart';
import '../../../data/models/receipt_editor_config.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MenuLayoutPage(
        selectedKey: controller.selectedMenu.value,
        contentBuilder: _buildContent,
        menuWidget: _buildSidebar(),
        centerContent: true,
      ),
    );
  }

  Widget _buildSidebar() {
    final menuItems = [
      const MenuItem(
        key: 'external_card_reader',
        label: '读卡器',
        icon: Icons.nfc,
      ),
      const MenuItem(key: 'qr_scanner', label: '二维码扫描仪', icon: Icons.qr_code_2),
      const MenuItem(key: 'external_printer', label: '打印机', icon: Icons.print),
      const MenuItem(
        key: 'network_detection',
        label: '网络检测',
        icon: Icons.network_check,
      ),
      const MenuItem(
        key: 'receipt_config',
        label: '小票配置',
        icon: Icons.receipt_long,
      ),
      const MenuItem(
        key: 'card_registration',
        label: '卡片登记',
        icon: Icons.card_membership,
      ),
      const MenuItem(
        key: 'game_card_management',
        label: '游戏卡管理',
        icon: Icons.games,
      ),
      const MenuItem(key: 'change_password', label: '修改登录密码', icon: Icons.lock),
      const MenuItem(key: 'version_check', label: '版本检查', icon: Icons.info),
    ];

    return Obx(
      () => CommonMenu(
        menuItems: menuItems,
        selectedKey: controller.selectedMenu.value,
        onItemSelected: (key) => controller.selectMenu(key),
        // backgroundColor: const Color(0xFF2C3E50),
        width: 200.w,
      ),
    );
  }

  Widget _buildContent(String selectedMenu) {
    switch (selectedMenu) {
      case 'external_card_reader':
        return const ExternalCardReaderView();
      case 'qr_scanner':
        return const QrScannerConfigView();
      case 'external_printer':
        return const ExternalPrinterView();
      case 'network_detection':
        _ensureNetworkCheckController();
        return const NetworkCheckWidget();
      case 'receipt_config':
        return const ReceiptConfigPage();
      case 'card_registration':
        return const CardRegistrationView();
      case 'game_card_management':
        return const GameCardManagementView();
      case 'version_check':
        _ensureVersionCheckController();
        return const VersionCheckView();
      case 'change_password':
        return const ChangePasswordView();
      default:
        return const PlaceholderView();
    }
  }

  void _ensureNetworkCheckController() {
    if (!Get.isRegistered<NetworkCheckController>()) {
      Get.put(NetworkCheckController());
      print('✓ 创建 NetworkCheckController');
    }
  }

  void _ensureVersionCheckController() {
    if (!Get.isRegistered<VersionCheckController>()) {
      Get.put(VersionCheckController());
    }
  }
}
