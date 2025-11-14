/// QuickRefundPage
/// 快速退卡页面

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_theme.dart';

class QuickRefundPage extends StatelessWidget {
  const QuickRefundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '快速退卡',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
