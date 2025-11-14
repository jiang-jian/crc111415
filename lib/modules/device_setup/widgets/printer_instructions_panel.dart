import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// 打印机配置操作提示面板组件（优化版 - 更紧凑）
class PrinterInstructionsPanel extends StatelessWidget {
  const PrinterInstructionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.infoBgColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16.sp,
                color: AppTheme.infoColor,
              ),
              SizedBox(width: 6.w),
              Text(
                '操作提示',
                style: AppTheme.textBody.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.infoColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildInstructionItem('1', '自动检测打印机状态'),
          SizedBox(height: AppTheme.spacingS),
          _buildInstructionItem('2', '状态正常后点击测试打印'),
          SizedBox(height: AppTheme.spacingS),
          _buildInstructionItem('3', '右侧日志显示SDK调用详情'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 20.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.infoColor,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: Text(
            text,
            style: AppTheme.textCaption.copyWith(
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
