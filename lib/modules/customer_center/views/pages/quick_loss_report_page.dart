/// QuickLossReportPage
/// 快速挂失页面

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_theme.dart';

class QuickLossReportPage extends StatelessWidget {
  const QuickLossReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '快速挂失',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
