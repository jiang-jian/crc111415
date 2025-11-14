import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

class GameCardManagementView extends StatelessWidget {
  const GameCardManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.games, size: 80.sp, color: AppTheme.borderColor),
          SizedBox(height: 24.h),
          Text(
            '游戏卡管理',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '此功能正在开发中...',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}
