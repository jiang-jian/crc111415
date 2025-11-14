/// DeactivateCardDialog
/// 注销技术卡对话框

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/dialog.dart';
import '../../../core/widgets/toast.dart';

class DeactivateCardDialog {
  static Future<void> show(
    BuildContext context, {
    required String cardNumber,
    required Function(String cardNumber) onCardDeactivated,
  }) async {
    await AppDialog.custom(
      title: '注销技术卡',
      content: _DeactivateCardContent(cardNumber: cardNumber),
      confirmText: '确定',
      cancelText: '取消',
      width: 450.w,
      barrierDismissible: false,
      isDanger: true,
      onConfirm: () {
        onCardDeactivated(cardNumber);
        Toast.success(message: '技术卡注销成功！卡号：$cardNumber');
      },
    );
  }
}

class _DeactivateCardContent extends StatelessWidget {
  final String cardNumber;

  const _DeactivateCardContent({required this.cardNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoField(label: '技术卡号', value: cardNumber),
        SizedBox(height: 20.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.spacingDefault),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            border: Border.all(color: const Color(0xFFFFE0B2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFFF9800),
                size: 20.sp,
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  '注销技术卡成功之后，不可对商户内一体机进行操作',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGrey,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
