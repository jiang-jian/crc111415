/// DepositCoinPage
/// 存币页面

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_theme.dart';

class DepositCoinPage extends StatelessWidget {
  const DepositCoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '存币',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
