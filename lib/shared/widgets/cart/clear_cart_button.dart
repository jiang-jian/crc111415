import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../modules/cashier/models/cart_item.dart';
import '../../../core/widgets/dialog.dart';

/// ClearCartButton
/// 统一清空购物车按钮

class ClearCartButton extends StatelessWidget {
  final RxList<CartItem> cartItems;
  final VoidCallback onClearCart;

  const ClearCartButton({
    super.key,
    required this.cartItems,
    required this.onClearCart,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasItems = cartItems.isNotEmpty;

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: hasItems ? 1.0 : .3,
        child: InkWell(
          onTap: hasItems ? () => _showClearConfirmDialog(context) : null,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: hasItems
                  ? AppTheme.errorColor.withValues(alpha: .1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
              border: Border.all(
                color: hasItems ? AppTheme.errorColor : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 16.w,
                  color: hasItems ? AppTheme.errorColor : Colors.grey.shade400,
                ),
                SizedBox(width: AppTheme.spacingXS),
                Text(
                  '清空',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: hasItems
                        ? AppTheme.errorColor
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showClearConfirmDialog(BuildContext context) async {
    final result = await AppDialog.confirm(
      title: '确认清空',
      message: '您确定要清空购物车吗?',
    );
    if (result) {
      onClearCart();
    }
  }
}
