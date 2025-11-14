/// CartSectionContainer
/// 统一购物车区域容器

import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../modules/cashier/models/cart_item.dart';
import 'package:get/get.dart';
import 'clear_cart_button.dart';

class CartSectionContainer extends StatelessWidget {
  final String title;
  final RxList<CartItem> cartItems;
  final VoidCallback onClearCart;
  final Widget cartListView;
  final Widget? extraInfoSection;
  final Widget totalAmountBar;
  final Widget paymentSelector;
  final Widget checkoutButton;

  const CartSectionContainer({
    super.key,
    required this.title,
    required this.cartItems,
    required this.onClearCart,
    required this.cartListView,
    this.extraInfoSection,
    required this.totalAmountBar,
    required this.paymentSelector,
    required this.checkoutButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTheme.textTitle),
                ClearCartButton(cartItems: cartItems, onClearCart: onClearCart),
              ],
            ),
          ),
          Expanded(child: cartListView),
          if (extraInfoSection != null) extraInfoSection!,
          totalAmountBar,
          paymentSelector,
          checkoutButton,
        ],
      ),
    );
  }
}
