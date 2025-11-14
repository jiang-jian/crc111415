/// LossReportListPage
/// 挂失列表页面

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_theme.dart';

class LossReportListPage extends StatelessWidget {
  const LossReportListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '挂失列表',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
