/// MemberAssetsDrawer
/// 会员资产抽屉 - 展示会员的各类资产信息

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/drawer.dart';
import '../../../core/widgets/dialog.dart';
import 'member_login_controller.dart';
import '../../../core/widgets/toast.dart';

class MemberAssetsDrawer extends StatelessWidget {
  const MemberAssetsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberLoginController>();

    return Container(
      width: 320.w,
      color: const Color(0xFFF6F6F6),
      child: Column(
        children: [
          // _buildHeader(controller),
          Expanded(child: _buildAssetsList()),
          _buildLogoutButton(context, controller),
        ],
      ),
    );
  }

  Widget _buildAssetsList() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      children: [
        _buildAssetItem(
          icon: Icons.account_balance_wallet,
          iconColor: const Color(0xFFFFB800),
          label: '游戏币',
          value: '1,234',
        ),
        _buildAssetItem(
          icon: Icons.stars,
          iconColor: AppTheme.errorColor,
          label: '超级币',
          value: '567',
        ),
        _buildAssetItem(
          icon: Icons.card_giftcard,
          iconColor: AppTheme.successColor,
          label: '彩票',
          value: '89',
        ),
        _buildAssetItem(
          icon: Icons.confirmation_number,
          iconColor: AppTheme.infoColor,
          label: '优惠券',
          value: '12',
          trailing: '张',
        ),
        _buildAssetItem(
          icon: Icons.local_activity,
          iconColor: const Color(0xFF722ED1),
          label: '门票',
          value: '5',
          trailing: '张',
        ),
        _buildAssetItem(
          icon: Icons.extension,
          iconColor: const Color(0xFFEB2F96),
          label: '道具(共享)',
          value: '23',
          trailing: '个',
        ),
        _buildAssetItem(
          icon: Icons.redeem,
          iconColor: const Color(0xFFFA8C16),
          label: '盲盒',
          value: '3',
          trailing: '个',
        ),
      ],
    );
  }

  Widget _buildAssetItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String trailing = '',
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            ),
            child: Icon(icon, size: 24.sp, color: iconColor),
          ),
          SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          if (trailing.isNotEmpty) ...[
            SizedBox(width: AppTheme.spacingXS),
            Text(
              trailing,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
            ),
          ],
          SizedBox(width: AppTheme.spacingS),
          Icon(Icons.chevron_right, size: 20.sp, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    MemberLoginController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 8.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: OutlinedButton(
          onPressed: () {
            CustomDrawer.hide();
            _showLogoutConfirmDialog(context, controller);
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.errorColor, width: 1.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 18.sp, color: AppTheme.errorColor),
              SizedBox(width: AppTheme.spacingS),
              Text(
                '退出登录',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmDialog(
    BuildContext context,
    MemberLoginController controller,
  ) async {
    final result = await AppDialog.confirm(
      title: '确认退出',
      message: '您确定要退出会员登录吗?',
    );

    if (result) {
      controller.logout();
      Toast.success(message: '已退出会员登录');
    }
  }
}
