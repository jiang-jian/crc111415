/// CashPaymentDialog
/// 现金收银对话框
/// 显示应收/实收/找零，数字键盘用于输入实收金额

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/dialog.dart';
import '../../../../core/widgets/loading.dart';
import '../../controllers/cashier_controller.dart';

class CashPaymentDialog {
  static Future<void> show(BuildContext context) async {
    final controller = Get.find<CashierController>();
    final isLoading = ValueNotifier<bool>(false);
    final canConfirm = ValueNotifier<bool>(false);

    // 同步 GetX 状态到 ValueNotifier
    final subscription = controller.paymentController.isCheckingOut.listen((
      value,
    ) {
      isLoading.value = value;
    });

    try {
      await AppDialog.custom(
        title: '现金收银',
        content: _CashPaymentContent(canConfirmNotifier: canConfirm),
        confirmText: '确认收款',
        width: 500,
        maxHeight: 700,
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

class _CashPaymentContent extends StatefulWidget {
  final ValueNotifier<bool> canConfirmNotifier;

  const _CashPaymentContent({required this.canConfirmNotifier});

  @override
  State<_CashPaymentContent> createState() => _CashPaymentContentState();
}

class _CashPaymentContentState extends State<_CashPaymentContent> {
  final TextEditingController _receivedController = TextEditingController();

  @override
  void dispose() {
    _receivedController.dispose();
    super.dispose();
  }

  void _updateCanConfirm() {
    final controller = Get.find<CashierController>();
    final totalAmount = controller.totalAmount;
    final received = double.tryParse(_receivedController.text) ?? 0;
    widget.canConfirmNotifier.value = received >= totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CashierController>();
    final totalAmount = controller.totalAmount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAmountRow('应收金额', totalAmount, isPrimary: true),
        SizedBox(height: 12.h),
        _buildReceivedInputRow(),
        SizedBox(height: 12.h),
        _buildChangeRow(),
        SizedBox(height: 24.h),
        _buildNumericKeypad(),
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

  Widget _buildReceivedInputRow() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '实收金额',
            style: TextStyle(fontSize: 15.sp, color: AppTheme.textSecondary),
          ),
          SizedBox(
            width: 200.w,
            child: TextField(
              controller: _receivedController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                border: InputBorder.none,
                prefix: Text('AED ', style: TextStyle(fontSize: 16.sp)),
              ),
              onChanged: (_) {
                setState(() {});
                _updateCanConfirm();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeRow() {
    final controller = Get.find<CashierController>();
    final totalAmount = controller.totalAmount;
    final received = double.tryParse(_receivedController.text) ?? 0;
    final change = received - totalAmount;

    return Container(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        color: change >= 0 ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '找零',
            style: TextStyle(fontSize: 15.sp, color: AppTheme.textSecondary),
          ),
          Text(
            'AED ${change >= 0 ? change.toStringAsFixed(2) : '0.00'}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: change >= 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
      ),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          SizedBox(height: 8.h),
          _buildKeypadRow(['4', '5', '6']),
          SizedBox(height: 8.h),
          _buildKeypadRow(['7', '8', '9']),
          SizedBox(height: 8.h),
          _buildKeypadRow(['.', '0', '⌫']),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildKeyButton(key),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyButton(String key) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
      },
      onTap: () => _handleKeyPress(key),
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: key == '⌫' ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleKeyPress(key),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            splashColor: key == '⌫'
                ? Colors.red.withValues(alpha: .1)
                : AppTheme.primaryColor.withValues(alpha: .1),
            highlightColor: key == '⌫'
                ? Colors.red.withValues(alpha: .05)
                : AppTheme.primaryColor.withValues(alpha: .05),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: key == '⌫'
                      ? Colors.red.shade700
                      : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleKeyPress(String key) {
    final currentText = _receivedController.text;

    if (key == '⌫') {
      if (currentText.isNotEmpty) {
        _receivedController.text = currentText.substring(
          0,
          currentText.length - 1,
        );
      }
    } else if (key == '.') {
      if (!currentText.contains('.')) {
        _receivedController.text = currentText.isEmpty ? '0.' : '$currentText.';
      }
    } else {
      // 限制小数点后两位
      if (currentText.contains('.')) {
        final parts = currentText.split('.');
        if (parts[1].length >= 2) return;
      }
      _receivedController.text = currentText + key;
    }

    setState(() {});
    _updateCanConfirm();
  }
}
