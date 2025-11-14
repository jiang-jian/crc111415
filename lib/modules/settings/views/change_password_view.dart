import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/widgets/change_password_form.dart';
import '../../../app/theme/app_theme.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '修改登录密码',
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40.h),
              Container(
                constraints: BoxConstraints(maxWidth: 600.w),
                padding: EdgeInsets.all(AppTheme.spacingM),
                child: const ChangePasswordForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
