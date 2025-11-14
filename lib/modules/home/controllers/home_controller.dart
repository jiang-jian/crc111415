import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routes/router_config.dart';

class HomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final username = ''.obs;
  final merchantCode = ''.obs;
  final cashierNumber = 'NO.00000'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
  }

  void loadUserInfo() {
    final storedUsername = _storage.getString(StorageKeys.username);
    username.value = storedUsername ?? 'Guest';
    merchantCode.value =
        _storage.getString(StorageKeys.merchantCode) ?? '100000';
  }

  /// 根据时间获取问候语
  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return '上午好';
    } else if (hour >= 12 && hour < 18) {
      return '下午好';
    } else {
      return '晚上好';
    }
  }

  /// 根据时间获取问候图标
  IconData get greetingIcon {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny_outlined; // 太阳
    } else if (hour >= 12 && hour < 18) {
      return Icons.wb_cloudy_outlined; // 云朵
    } else {
      return Icons.nights_stay_outlined; // 月亮
    }
  }

  /// 根据时间获取问候图标颜色
  Color get greetingIconColor {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return const Color(0xFFF39C12); // 橙色 - 早晨
    } else if (hour >= 12 && hour < 18) {
      return const Color(0xFF3498DB); // 蓝色 - 下午
    } else {
      return const Color(0xFF9B59B6); // 紫色 - 晚上
    }
  }

  /// 根据时间获取鼓励语
  String get encouragementText {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return '新的一天，新的开始，加油！';
    } else if (hour >= 12 && hour < 18) {
      return '继续保持热情，下午也要元气满满！';
    } else {
      return '辛苦了一天，感谢你的付出！';
    }
  }

  void onMenuTap(String? path) {
    if (path == null || path.isEmpty) {
      print('Menu path is null or empty, no navigation');
      return;
    }
    AppRouter.push(path);
  }

  void goToComponentsDemo() {
    AppRouter.push('/components-demo');
  }

  void goToDeviceSetup() {
    AppRouter.push('/device-setup');
  }
}
