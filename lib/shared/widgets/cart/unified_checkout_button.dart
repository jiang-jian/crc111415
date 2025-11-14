/// UnifiedCheckoutButton
/// 统一结账按钮

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../modules/cashier/models/cart_item.dart';

class UnifiedCheckoutButton extends StatelessWidget {
  final RxBool isCheckingOut;
  final Rx<bool?>? hasPaymentMethod;
  final RxList<CartItem> cartItems;
  final String buttonText;
  final Future<void> Function(BuildContext) onCheckout;

  const UnifiedCheckoutButton({
    super.key,
    required this.isCheckingOut,
    this.hasPaymentMethod,
    required this.cartItems,
    required this.buttonText,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final processing = isCheckingOut.value;
      final hasMethod = hasPaymentMethod?.value ?? true;
      final hasItems = cartItems.isNotEmpty;
      final isDisabled = processing || !hasMethod || !hasItems;

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: isDisabled ? null : () => onCheckout(context),
            child: processing
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
