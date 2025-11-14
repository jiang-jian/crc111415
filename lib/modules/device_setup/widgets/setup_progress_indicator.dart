import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// 设备初始化进度指示器
class SetupProgressIndicator extends StatelessWidget {
  final int currentStep; // 当前步骤 (1-4)
  final int totalSteps; // 总步骤数

  const SetupProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber < currentStep;
        final isCurrent = stepNumber == currentStep;

        return Row(
          children: [
            // 步骤条
            Container(
              width: isCurrent ? 150.w : 140.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppTheme
                          .primaryColor // 金黄色
                    : AppTheme.borderColor, // 灰色
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ),
            // 间隔（最后一个不显示）
            if (index < totalSteps - 1) SizedBox(width: AppTheme.spacingS),
          ],
        );
      }),
    );
  }
}
