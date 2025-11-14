/// PaymentMethodSelector
/// 支付方式选择器

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_theme.dart';
import '../../controllers/cashier_controller.dart';

class PaymentMethodSelector extends GetView<CashierController> {
  const PaymentMethodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final enabledMethods = controller.paymentController.enabledPaymentMethods;

      if (enabledMethods.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: enabledMethods.asMap().entries.map((entry) {
            final index = entry.key;
            final config = entry.value;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < enabledMethods.length - 1 ? 12.w : 0,
                ),
                child: _buildPaymentButton(
                  label: config.method == PaymentMethod.card ? '刷卡' : '现金',
                  icon: config.method == PaymentMethod.card
                      ? Icons.credit_card
                      : Icons.payments_outlined,
                  method: config.method,
                  isSelected:
                      controller
                          .paymentController
                          .selectedPaymentMethod
                          .value ==
                      config.method,
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildPaymentButton({
    required String label,
    required IconData icon,
    required PaymentMethod method,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => controller.paymentController.selectPaymentMethod(method),
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
      child: AnimatedContainer(
        duration: isSelected
            ? const Duration(milliseconds: 200)
            : Duration.zero,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: .1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28.w,
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
