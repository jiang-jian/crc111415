import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/storage/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/auth_service.dart';
import '../../core/utils/navigation_helper.dart';
import '../../core/widgets/dialog.dart';
import 'change_password_form.dart';

/// AppHeader 专用控制器
/// 管理头部组件的交互逻辑，包括修改密码、退出登录等
class AppHeaderController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _authService = AuthService();

  /// 显示退出登录确认对话框
  Future<void> showLogoutDialog(BuildContext context) async {
    final result = await AppDialog.confirm(
      title: '确认退出',
      message: '您确定要退出登录吗?',
    );
    if (result) {
      await logout();
    }
  }

  /// 退出登录
  Future<void> logout() async {
    print('logout');
    try {
      // 先调用退出登录 API（此时 token 还在，可以正常请求）
      await _authService.logout();
    } catch (e) {
      debugPrint('退出登录 API 调用失败: $e');
    }
    print('logout success');
    // 清除本地存储的用户数据
    await _storage.remove(StorageKeys.token);
    await _storage.remove(StorageKeys.tokenName);
    await _storage.remove(StorageKeys.userId);
    await _storage.remove(StorageKeys.username);
    await _storage.remove(StorageKeys.merchantCode);

    // 使用导航辅助类，自动清理首页相关 Controller
    NavigationHelper.homeToLogin();
  }

  /// 显示修改密码对话框
  Future<void> showChangePasswordDialog(BuildContext context) async {
    await AppDialog.custom(
      title: '修改登录密码',
      content: ChangePasswordForm(
        onSuccess: () {
          AppDialog.hide(true);
        },
        onCancel: () {
          AppDialog.hide(false);
        },
      ),
      width: 450.w,
      showConfirm: false,
      showCancel: false,
    );
  }
}
