import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/home_controller.dart';
import '../widgets/menu_card.dart';
import '../../../l10n/app_localizations.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            _buildInfoBar(context, l10n),
            SizedBox(height: AppTheme.spacingM),
            _buildMenuGrid(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingM,
      ),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          // 左侧：欢迎信息
          Expanded(child: _buildWelcomeSection(l10n)),
          // 中间分割线
          Container(
            width: 1.w,
            height: 32.h,
            color: AppTheme.borderColor.withValues(alpha: .5),
            margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
          ),
          // 右侧：信息区域
          _buildInfoSection(l10n),
        ],
      ),
    );
  }

  /// 欢迎区域
  Widget _buildWelcomeSection(AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          controller.greetingIcon,
          size: 20.sp,
          color: controller.greetingIconColor,
        ),
        SizedBox(width: AppTheme.spacingS),
        Text(
          controller.greetingText,
          style: AppTheme.textBody.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(width: AppTheme.spacingXS),
        Obx(
          () => Text(
            controller.username.value,
            style: AppTheme.textBody.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingM),
        Text(
          controller.encouragementText,
          style: AppTheme.textCaption.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  /// 信息区域
  Widget _buildInfoSection(AppLocalizations l10n) {
    return Row(
      children: [
        _buildInfoItem(
          icon: Icons.phone_outlined,
          label: l10n.customerService,
          value: '400-223-1133',
        ),
        SizedBox(width: AppTheme.spacingXL),
        Obx(
          () => _buildInfoItem(
            icon: Icons.store_outlined,
            label: l10n.merchantCode,
            value: controller.merchantCode.value,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppTheme.textSecondary),
        SizedBox(width: AppTheme.spacingS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.textCaption.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: AppTheme.textCaption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGrid(AppLocalizations l10n) {
    final menus = [
      {
        'title': l10n.quickCheckout,
        'icon': Icons.shopping_cart_outlined,
        'color': AppTheme.primaryColor,
        'path': '/cashier',
        'enabled': true,
      },
      {
        'title': l10n.giftExchange,
        'icon': Icons.card_giftcard_outlined,
        'color': AppTheme.primaryColor,
        'path': '/gift-exchange',
        'enabled': true,
      },
      {
        'title': l10n.customerCenter,
        'icon': Icons.people_outline,
        'color': AppTheme.primaryColor,
        'path': '/customer-center',
        'enabled': true,
      },
      {
        'title': l10n.exchangeVerification,
        'icon': Icons.verified_outlined,
        'color': AppTheme.primaryColor,
        'path': null,
        'enabled': false,
      },
      {
        'title': l10n.activityCenter,
        'icon': Icons.celebration_outlined,
        'color': AppTheme.primaryColor,
        'path': null,
        'enabled': false,
      },
      {
        'title': l10n.orderCenter,
        'icon': Icons.receipt_long_outlined,
        'color': AppTheme.primaryColor,
        'path': null,
        'enabled': false,
      },
      {
        'title': l10n.businessReport,
        'icon': Icons.analytics_outlined,
        'color': AppTheme.primaryColor,
        'path': null,
        'enabled': false,
      },
      {
        'title': l10n.financialManagement,
        'icon': Icons.account_balance_outlined,
        'color': AppTheme.primaryColor,
        'path': null,
        'enabled': false,
      },
      {
        'title': '设备初始化',
        'icon': Icons.devices_outlined,
        'color': AppTheme.primaryColor,
        'path': '/device-setup',
        'enabled': true,
      },
      {
        'title': 'Sunmi SDK',
        'icon': Icons.integration_instructions_outlined,
        'color': AppTheme.primaryColor,
        'path': '/sunmi-customer-api',
        'enabled': true,
      },
      {
        'title': l10n.settings,
        'icon': Icons.settings_outlined,
        'color': AppTheme.primaryColor,
        'path': '/settings',
        'enabled': true,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: AppTheme.spacingM,
        mainAxisSpacing: AppTheme.spacingM,
        childAspectRatio: 1.3,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return MenuCard(
          title: menu['title'] as String,
          icon: menu['icon'] as IconData?,
          color: menu['color'] as Color,
          isEnabled: menu['enabled'] as bool,
          onTap: () => controller.onMenuTap(menu['path'] as String?),
        );
      },
    );
  }
}
