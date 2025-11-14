/// MemberRegistrationDialog
/// 会员注册对话框，快速发卡功能
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import 'member_login_controller.dart';
import '../../../core/widgets/toast.dart';

class MemberRegistrationDialog extends StatefulWidget {
  const MemberRegistrationDialog({super.key});

  @override
  State<MemberRegistrationDialog> createState() =>
      _MemberRegistrationDialogState();
}

class _MemberRegistrationDialogState extends State<MemberRegistrationDialog> {
  bool isReading = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberLoginController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
      ),
      child: Container(
        width: 480.w,
        padding: EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '快速发卡',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: .2),
                  width: 1.w,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 48.sp,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '请拿一张游玩卡刷卡获取卡号',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusDefault,
                ),
                border: Border.all(color: AppTheme.borderColor, width: 1.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '卡号',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => Text(
                      controller.cardNumber.value.isEmpty
                          ? '等待读卡...'
                          : controller.cardNumber.value,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: controller.cardNumber.value.isEmpty
                            ? AppTheme.textSecondary
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.resetCardNumber();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 20.h,
                      ),
                      side: BorderSide(color: AppTheme.borderColor, width: 1.w),
                    ),
                    child: Text('取消', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(width: AppTheme.spacingDefault),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.cardNumber.value.isEmpty
                          ? () async {
                              if (isReading) return;
                              setState(() {
                                isReading = true;
                              });
                              await controller.simulateReadCard();
                              setState(() {
                                isReading = false;
                              });
                            }
                          : () {
                              Navigator.of(context).pop();
                              Toast.success(
                                message:
                                    '发卡成功\n卡号：${controller.cardNumber.value}',
                              );
                              controller.resetCardNumber();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.w,
                          vertical: 20.h,
                        ),
                      ),
                      child: Text(
                        isReading
                            ? '读卡中...'
                            : controller.cardNumber.value.isEmpty
                            ? '读卡'
                            : '发卡',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
