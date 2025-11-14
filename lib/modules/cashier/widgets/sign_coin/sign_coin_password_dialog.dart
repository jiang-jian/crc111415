import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/dialog.dart';
import '../../controllers/sign_coin_controller.dart';

/// SignCoinPasswordDialog
/// 签币密码验证对话框（使用全局 AppDialog 组件）
class SignCoinPasswordDialog {
  static Future<void> show(BuildContext context) async {
    final controller = Get.find<SignCoinController>();
    final passwordController = TextEditingController();
    final isLoadingNotifier = ValueNotifier<bool>(false);
    final canConfirmNotifier = ValueNotifier<bool>(false);
    final errorMessageNotifier = ValueNotifier<String>('');
    final obscurePasswordNotifier = ValueNotifier<bool>(true);

    void handleConfirm() async {
      final password = passwordController.text.trim();

      if (password.isEmpty) {
        errorMessageNotifier.value = '请输入密码';
        return;
      }

      isLoadingNotifier.value = true;
      errorMessageNotifier.value = '';

      await Future.delayed(const Duration(milliseconds: 300));

      if (!controller.verifyPassword(password)) {
        isLoadingNotifier.value = false;
        errorMessageNotifier.value = '密码错误，请重新输入';
        passwordController.clear();
        canConfirmNotifier.value = false;
        return;
      }

      if (context.mounted) {
        await controller.confirmSignCoin(context);
      }
      isLoadingNotifier.value = false;
      AppDialog.hide(true);
    }

    passwordController.addListener(() {
      canConfirmNotifier.value = passwordController.text.trim().isNotEmpty;
      if (errorMessageNotifier.value.isNotEmpty) {
        errorMessageNotifier.value = '';
      }
    });

    await AppDialog.custom(
      title: '密码验证',
      content: _PasswordInputContent(
        controller: controller,
        passwordController: passwordController,
        errorMessageNotifier: errorMessageNotifier,
        obscurePasswordNotifier: obscurePasswordNotifier,
        onSubmitted: handleConfirm,
      ),
      confirmText: '确定',
      cancelText: '取消',
      onConfirm: handleConfirm,
      isLoadingNotifier: isLoadingNotifier,
      canConfirmNotifier: canConfirmNotifier,
      autoCloseOnConfirm: false,
      barrierDismissible: false,
    );

    passwordController.dispose();
    isLoadingNotifier.dispose();
    canConfirmNotifier.dispose();
    errorMessageNotifier.dispose();
    obscurePasswordNotifier.dispose();
  }
}

class _PasswordInputContent extends StatelessWidget {
  final SignCoinController controller;
  final TextEditingController passwordController;
  final ValueNotifier<String> errorMessageNotifier;
  final ValueNotifier<bool> obscurePasswordNotifier;
  final VoidCallback onSubmitted;

  const _PasswordInputContent({
    required this.controller,
    required this.passwordController,
    required this.errorMessageNotifier,
    required this.obscurePasswordNotifier,
    required this.onSubmitted,
  });

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required Widget suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: AppTheme.textBody.copyWith(color: Colors.black54),
      hintStyle: AppTheme.textBody.copyWith(color: Colors.black38),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.errorColor, width: 2.w),
      ),
      errorStyle: AppTheme.textCaption.copyWith(color: AppTheme.errorColor),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.error)) {
          return AppTheme.textBody.copyWith(color: AppTheme.errorColor);
        }
        return AppTheme.textBody.copyWith(color: AppTheme.primaryColor);
      }),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingDefault,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline, size: 48.w, color: AppTheme.primaryColor),
        SizedBox(height: AppTheme.spacingDefault),
        Obx(
          () => Text(
            '请输入 ${controller.selectedPerson?.name ?? ''} 的密码',
            style: AppTheme.textSubtitle.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacingL),
        ValueListenableBuilder<bool>(
          valueListenable: obscurePasswordNotifier,
          builder: (context, obscurePassword, _) {
            return TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              autofocus: true,
              onSubmitted: (_) => onSubmitted(),
              style: AppTheme.textSubtitle.copyWith(color: Colors.black87),
              decoration: _buildInputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    size: 18.sp,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    obscurePasswordNotifier.value = !obscurePassword;
                  },
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder<String>(
          valueListenable: errorMessageNotifier,
          builder: (context, errorMessage, _) {
            return errorMessage.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: AppTheme.spacingS),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        errorMessage,
                        style: AppTheme.textCaption.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
