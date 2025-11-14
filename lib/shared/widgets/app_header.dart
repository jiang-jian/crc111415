import 'package:ailand_pos/app/routes/router_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../core/controllers/locale_controller.dart';
import 'marquee_text.dart';
import 'app_header_controller.dart';
import 'breadcrumb.dart';
import 'member_login/member_login_button.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  /// 检查当前是否在绑定页面
  bool _isBindingPage(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    return currentRoute == '/bind-cashier';
  }

  /// 检查当前是否在收银台页面
  bool _isCashierPage(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    return currentRoute == '/cashier';
  }

  /// 检查当前是否在礼品兑换页面
  bool _isGiftExchangePage(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    return currentRoute == '/gift-exchange';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final homeController = Get.find<HomeController>();
    final headerController = Get.find<AppHeaderController>();
    final localeController = Get.find<LocaleController>();

    final isBindingPage = _isBindingPage(context);
    final isCashierPage = _isCashierPage(context);
    final isGiftExchangePage = _isGiftExchangePage(context);
    final showMemberLogin = isCashierPage || isGiftExchangePage;

    return Container(
      height: 72.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: .5),
            width: 1.w,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            offset: Offset(0, 2.h),
            blurRadius: 8.r,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingDefault,
      ),
      child: Row(
        children: [
          // 左侧：用户信息 + 门店 + 面包屑
          _buildUserInfo(context, l10n, homeController, headerController),
          SizedBox(width: AppTheme.spacingDefault),
          _buildStoreName(),
          SizedBox(width: AppTheme.spacingM),
          Icon(Icons.chevron_right, size: 16.sp, color: AppTheme.textTertiary),
          SizedBox(width: AppTheme.spacingM),
          _buildBreadcrumb(context, isBindingPage),
          SizedBox(width: AppTheme.spacingL),

          // 中间：跑马灯通知（自动填充剩余空间）
          if (!showMemberLogin) ...[
            Expanded(child: _buildMarqueeNotice()),
            SizedBox(width: AppTheme.spacingL),
          ] else
            const Spacer(),

          // 右侧：功能按钮组
          _buildActionButtons(
            context,
            localeController,
            isBindingPage,
            showMemberLogin,
          ),
        ],
      ),
    );
  }

  /// 用户信息
  Widget _buildUserInfo(
    BuildContext context,
    AppLocalizations l10n,
    HomeController homeController,
    AppHeaderController headerController,
  ) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'change_password',
          child: Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: 18.sp,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: AppTheme.spacingM),
              Text('修改登录密码', style: AppTheme.textBody),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18.sp, color: AppTheme.errorColor),
              SizedBox(width: AppTheme.spacingM),
              Text(
                '交班退出登录',
                style: AppTheme.textBody.copyWith(color: AppTheme.errorColor),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'change_password') {
          headerController.showChangePasswordDialog(context);
        } else if (value == 'logout') {
          headerController.showLogoutDialog(context);
        }
      },
      child: Obx(
        () => Container(
          height: 40.h,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingDefault,
            vertical: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: .2),
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusLarge,
                  ),
                ),
                child: Icon(Icons.person, size: 14.sp, color: Colors.white),
              ),
              SizedBox(width: AppTheme.spacingS),
              Text(
                '${l10n.cashier}${homeController.username.value}',
                style: AppTheme.textBody.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: AppTheme.spacingXS),
              Icon(
                Icons.arrow_drop_down,
                size: 18.sp,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 门店名称
  Widget _buildStoreName() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.store_outlined, size: 16.sp, color: AppTheme.textSecondary),
        SizedBox(width: AppTheme.spacingXS),
        Text(
          '我是门店名称',
          style: AppTheme.textBody.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 面包屑导航
  Widget _buildBreadcrumb(BuildContext context, bool isBindingPage) {
    return Container(
      constraints: BoxConstraints(maxWidth: 300.w),
      child: Breadcrumb(
        items: Breadcrumb.fromContext(context),
        disabled: isBindingPage,
      ),
    );
  }

  /// 跑马灯通知
  Widget _buildMarqueeNotice() {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Row(
        children: [
          Icon(
            Icons.volume_up,
            size: 16.sp,
            color: AppTheme.textTertiary,
          ),
          SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: MarqueeText(
              text:
                  'This is a test message! System update! New promotion~This is a test message! System update! New promotion~This is a test message! System update! New promotion~This is a test message! System update! New promotion~',
              style: AppTheme.textBody.copyWith(
                color: AppTheme.textSecondary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 右侧功能按钮组
  Widget _buildActionButtons(
    BuildContext context,
    LocaleController localeController,
    bool isBindingPage,
    bool showMemberLogin,
  ) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey.withValues(alpha: .85),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTheme.rippleIconButton(
            icon: Icons.notifications_outlined,
            onTap: isBindingPage
                ? null
                : () => AppRouter.push('/notification-center'),
            showBadge: true,
            disabled: isBindingPage,
          ),
          _buildDivider(),
          Obx(
            () => _buildLanguageButton(
              localeController.currentLanguageText,
              () => localeController.toggleLocale(),
            ),
          ),
          _buildDivider(),
          AppTheme.rippleIconButton(icon: Icons.help_outline, onTap: () {}),
          if (showMemberLogin) ...[
            SizedBox(width: AppTheme.spacingS),
            Container(
              width: 1.w,
              height: 24.h,
              color: AppTheme.borderColor,
              margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
            ),
            const MemberLoginButton(),
          ],
        ],
      ),
    );
  }

  /// 分割线
  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 20.h,
      color: AppTheme.borderColor.withValues(alpha: .6),
      margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingXS),
    );
  }

  /// 构建语言切换按钮
  Widget _buildLanguageButton(String text, VoidCallback onPressed) {
    return AppTheme.rippleTextButton(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, size: 20.sp, color: AppTheme.textSecondary),
          SizedBox(width: 6.w),
          Text(
            text,
            style: AppTheme.textBody.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
