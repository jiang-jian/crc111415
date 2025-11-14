/// MemberLoginButton
/// 会员登录按钮组件，支持登录/登出状态切换
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/drawer.dart';
import 'member_login_controller.dart';
import 'member_login_dialog.dart';
import 'member_assets_drawer.dart';

class MemberLoginButton extends StatelessWidget {
  const MemberLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberLoginController());

    return Obx(
      () => controller.isLoggedIn.value
          ? _buildMemberInfo(context, controller)
          : _buildLoginButton(context),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        MemberLoginDialog.show(context);
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: .8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: .3),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 20.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              '会员登录',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberInfo(
    BuildContext context,
    MemberLoginController controller,
  ) {
    return InkWell(
      onTap: () {
        CustomDrawer.show(
          context: context,
          width: 480.w,
          child: const MemberAssetsDrawer(),
          topOffset: 72.h, // AppHeader 的高度（padding 16.h * 2 + content 40.h）
        );
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: .3),
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
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: .8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Icon(Icons.person, size: 14.sp, color: Colors.white),
            ),
            SizedBox(width: AppTheme.spacingS),
            Text(
              '${controller.memberName.value} ${controller.memberPhone.value}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: AppTheme.spacingS),
            Icon(
              Icons.arrow_drop_down,
              size: 20.sp,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
