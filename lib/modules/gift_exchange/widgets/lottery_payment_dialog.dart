/// LotteryPaymentDialog
/// 彩票支付确认弹窗

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/dialog.dart';
import '../../../core/widgets/loading.dart';
import '../controllers/gift_exchange_controller.dart';

class LotteryPaymentDialog {
  static Future<void> show(BuildContext context) async {
    final controller = Get.find<GiftExchangeController>();
    final isLoading = ValueNotifier<bool>(false);
    final canConfirm = ValueNotifier<bool>(false);

    // 初始化检查余额
    final balance = controller.paymentController.lotteryBalance.value;
    final total = controller.totalAmount;
    canConfirm.value = balance >= total;

    // 同步 GetX 状态到 ValueNotifier
    final subscription = controller.paymentController.isCheckingOut.listen((
      value,
    ) {
      isLoading.value = value;
    });

    try {
      await AppDialog.custom(
        title: '彩票支付',
        content: _LotteryPaymentContent(canConfirmNotifier: canConfirm),
        confirmText: '确认支付',
        width: 500.w,
        isLoadingNotifier: isLoading,
        canConfirmNotifier: canConfirm,
        onConfirm: () => _handlePayment(context),
      );
    } finally {
      subscription.cancel();
      isLoading.dispose();
    }
  }

  static Future<void> _handlePayment(BuildContext context) async {
    final controller = Get.find<GiftExchangeController>();

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

class _LotteryPaymentContent extends StatelessWidget {
  final ValueNotifier<bool> canConfirmNotifier;

  const _LotteryPaymentContent({required this.canConfirmNotifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBalanceRow(),
        SizedBox(height: 16.h),
        _buildAmountRow(),
        SizedBox(height: 24.h),
        _buildInsufficientWarning(),
      ],
    );
  }

  Widget _buildBalanceRow() {
    final controller = Get.find<GiftExchangeController>();

    return Obx(() {
      final balance = controller.paymentController.lotteryBalance.value;
      final total = controller.totalAmount;

      // 更新按钮状态
      WidgetsBinding.instance.addPostFrameCallback((_) {
        canConfirmNotifier.value = balance >= total;
      });

      return Container(
        padding: EdgeInsets.all(AppTheme.spacingDefault),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '当前彩票余额',
              style: TextStyle(fontSize: 15.sp, color: AppTheme.textSecondary),
            ),
            Row(
              children: [
                Text(
                  'AED ${balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: AppTheme.spacingS),
                InkWell(
                  onTap: () => controller.paymentController.refreshBalance(),
                  child: Icon(
                    Icons.refresh,
                    size: 20.w,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAmountRow() {
    final controller = Get.find<GiftExchangeController>();

    return Obx(() {
      final totalAmount = controller.totalAmount;

      return Container(
        padding: EdgeInsets.all(AppTheme.spacingDefault),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '应付金额',
              style: TextStyle(fontSize: 15.sp, color: AppTheme.textSecondary),
            ),
            Text(
              'AED ${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.priceColor,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInsufficientWarning() {
    final controller = Get.find<GiftExchangeController>();

    return Obx(() {
      final balance = controller.paymentController.lotteryBalance.value;
      final total = controller.totalAmount;
      final insufficient = balance < total;

      if (insufficient) {
        return Container(
          padding: EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.errorColor,
                size: 20.w,
              ),
              SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  '彩票余额不足，请先充值',
                  style: TextStyle(fontSize: 14.sp, color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
