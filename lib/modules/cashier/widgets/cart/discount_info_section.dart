/// DiscountInfoSection
/// 优惠信息展示区域

import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/cashier_controller.dart';

class DiscountInfoSection extends GetView<CashierController> {
  const DiscountInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cartController.cartItems.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 228, 227, 227),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        ),
        child: Column(
          children: [
            if (controller.paymentController.discountAmount > 0)
              _buildDiscountItem(
                '折扣优惠',
                controller.paymentController.discountAmount,
              ),
            if (controller.paymentController.packageDiscountAmount > 0)
              _buildDiscountItem(
                '套餐优惠',
                controller.paymentController.packageDiscountAmount,
              ),
            if (controller.paymentController.couponAmount > 0)
              _buildDiscountItem(
                '优惠券',
                controller.paymentController.couponAmount,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDiscountItem(String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            '-AED ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
