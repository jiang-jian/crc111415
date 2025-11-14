import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../widgets/quick_login_widget.dart';
import '../../network_check/widgets/network_check_widget.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: Row(
          children: [
            // 左侧：品牌与网络检测区域（白色背景）
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 48.h),
                child: Column(
                  children: [
                    // 品牌区域
                    SizedBox(height: 40.h),
                    _buildBrandSection(),
                    SizedBox(height: 60.h),
                    // 网络检测区域
                    const Expanded(child: NetworkCheckWidget()),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            // 右侧：登录区域（灰色背景）
            Expanded(
              flex: 3,
              child: Container(
                color: AppTheme.backgroundGrey,
                padding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 48.h),
                child: Center(child: _buildLoginSection(context, l10n)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 品牌区域
  Widget _buildBrandSection() {
    return Column(
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          child: Icon(
            Icons.storefront_rounded,
            size: 40.sp,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: AppTheme.spacingDefault),
        Text(
          'AILand POS',
          style: AppTheme.textHeading.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: AppTheme.spacingXS),
        Text(
          '智能收银系统',
          style: AppTheme.textCaption.copyWith(
            color: AppTheme.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 登录标题
        Text(
          '欢迎回来',
          style: TextStyle(
            fontSize: 42.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacingDefault),
        Text(
          '请选择账号或输入密码登录',
          style: AppTheme.textTitle.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 64.h),
        
        // 快速登录用户选择
        Container(
          padding: EdgeInsets.all(AppTheme.spacingXL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          child: const QuickLoginWidget(),
        ),
        
        SizedBox(height: AppTheme.spacingXL),
        
        // 输入框容器
        Container(
          padding: EdgeInsets.all(AppTheme.spacingXL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 180.h,
                child: Obx(
                  () => controller.isQuickLogin.value
                      ? _buildQuickLoginInputs(l10n, context)
                      : _buildFullLoginInputs(l10n, context),
                ),
              ),
              SizedBox(height: AppTheme.spacingL),
              _buildLoginButton(l10n, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullLoginInputs(AppLocalizations l10n, BuildContext context) {
    return Column(
      children: [
        _buildUsernameInput(l10n, context),
        SizedBox(height: AppTheme.spacingL),
        _buildPasswordInput(l10n, context),
      ],
    );
  }

  Widget _buildQuickLoginInputs(AppLocalizations l10n, BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: _buildPasswordInput(l10n, context),
    );
  }

  Widget _buildUsernameInput(AppLocalizations l10n, BuildContext context) {
    return TextField(
      controller: controller.usernameController,
      keyboardType: TextInputType.text,
      style: AppTheme.textSubtitle,
      decoration: InputDecoration(
        labelText: l10n.enterUsername,
        hintText: l10n.enterUsername,
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          size: 22.sp,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildPasswordInput(AppLocalizations l10n, BuildContext context) {
    return Obx(
      () => TextField(
        controller: controller.passwordController,
        obscureText: controller.obscurePassword.value,
        textInputAction: TextInputAction.done,
        style: AppTheme.textSubtitle,
        onSubmitted: (_) {
          if (!controller.isLoading.value) {
            controller.login(context);
          }
        },
        decoration: InputDecoration(
          labelText: l10n.enterPassword,
          hintText: l10n.enterPassword,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            size: 22.sp,
            color: AppTheme.textTertiary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword.value
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20.sp,
              color: AppTheme.textTertiary,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: Obx(
        () => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.backgroundDisabled,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            ),
            elevation: 0,
          ),
          onPressed: controller.isLoading.value
              ? null
              : () => controller.login(context),
          child: controller.isLoading.value
              ? SizedBox(
                  width: 22.w,
                  height: 22.h,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.w,
                  ),
                )
              : Text(
                  l10n.login,
                  style: AppTheme.textTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
