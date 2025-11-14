import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/auth/login_request.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/widgets/toast.dart';
import 'quick_login_controller.dart';

class LoginController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _authService = AuthService();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final isQuickLogin = false.obs;
  final selectedUsername = ''.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void selectQuickUser(String username) {
    usernameController.text = username;
    selectedUsername.value = username;
    isQuickLogin.value = true;
    passwordController.clear();
  }

  void clearQuickLogin() {
    usernameController.clear();
    passwordController.clear();
    selectedUsername.value = '';
    isQuickLogin.value = false;
  }

  Future<void> login(BuildContext context) async {
    // 验证账号
    if (usernameController.text.isEmpty) {
      Toast.error(message: '请输入账号');
      return;
    }

    // 验证密码
    final password = passwordController.text.trim();
    if (password.isEmpty) {
      Toast.error(message: '请输入密码');
      return;
    }

    isLoading.value = true;

    try {
      // 调用登录接口
      final request = LoginRequest(
        username: usernameController.text,
        password: password,
        deviceCode: 'flutter_device_001', // 临时设备码
      );

      final response = await _authService.login(request);

      // 保存用户信息
      if (response.token != null) {
        await _storage.setString(StorageKeys.token, response.token!);
      }
      if (response.tokenName != null) {
        await _storage.setString(StorageKeys.tokenName, response.tokenName!);
      }
      if (response.username != null) {
        await _storage.setString(StorageKeys.username, response.username!);
      }

      final quickLoginController = Get.find<QuickLoginController>();
      await quickLoginController.addUser(
        usernameController.text,
        response.username,
      );

      // 使用导航辅助类，自动清理登录相关 Controller
      NavigationHelper.loginToHome();
    } catch (e) {
      Toast.error(message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
