import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';

/// 语言控制器
/// 管理应用的国际化语言切换
class LocaleController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  static const String _localeKey = 'app_locale';

  // 当前语言
  final Rx<Locale> locale = Rx<Locale>(const Locale('zh', 'CN'));

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  /// 加载保存的语言设置
  Future<void> _loadSavedLocale() async {
    final savedLocale = _storage.getString(_localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        locale.value = Locale(parts[0], parts[1]);
      }
    }
  }

  /// 切换语言
  Future<void> toggleLocale() async {
    if (locale.value.languageCode == 'zh') {
      locale.value = const Locale('en', 'US');
      await _storage.setString(_localeKey, 'en_US');
    } else {
      locale.value = const Locale('zh', 'CN');
      await _storage.setString(_localeKey, 'zh_CN');
    }
  }

  /// 获取当前语言显示文本
  String get currentLanguageText {
    return locale.value.languageCode == 'zh' ? '中文' : 'EN';
  }
}
