/// CardPaymentDialog
/// 刷卡收银对话框
/// 显示应付金额和刷卡提示

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/dialog.dart';
import '../../../../core/widgets/loading.dart';
import '../../controllers/cashier_controller.dart';

class CardPaymentDialog {
  static Future<void> show(BuildContext context) async {
    final controller = Get.find<CashierController>();
    final isLoading = ValueNotifier<bool>(false);

    // 同步 GetX 状态到 ValueNotifier
    final subscription = controller.paymentController.isCheckingOut.listen((
      value,
    ) {
      isLoading.value = value;
    });

    try {
      await AppDialog.custom(
        title: '刷卡收银',
        content: const _CardPaymentContent(),
        confirmText: '确认收款',
        width: 500.w,
        isLoadingNotifier: isLoading,
        onConfirm: () => _handlePayment(context),
      );
    } finally {
      subscription.cancel();
      isLoading.dispose();
    }
  }

  static Future<void> _handlePayment(BuildContext context) async {
    final controller = Get.find<CashierController>();

    if (!context.mounted) return;

    Loading.show(message: '正在处理支付...');

    try {
      await controller.checkout();
      if (context.mounted) {
        AppDialog.hide(true);
      }
    } catch (e) {
      // 异常处理已在 controller 中完成
    } finally {
      Loading.hide();
    }
  }
}

class _CardPaymentContent extends StatelessWidget {
  const _CardPaymentContent();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CashierController>();
    final totalAmount = controller.totalAmount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAmountRow('应付金额', totalAmount, isPrimary: true),
        SizedBox(height: 24.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: .3),
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.nfc, size: 48.w, color: AppTheme.primaryColor),
              SizedBox(height: 12.h),
              Text(
                '请刷卡',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '请将银行卡靠近读卡器',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount, {
    bool isPrimary = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppTheme.primaryColor.withValues(alpha: .05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15.sp, color: AppTheme.textSecondary),
          ),
          Text(
            'AED ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isPrimary ? AppTheme.primaryColor : AppTheme.priceColor,
            ),
          ),
        ],
      ),
    );
  }
}
