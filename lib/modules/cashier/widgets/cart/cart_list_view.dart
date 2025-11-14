/// CartListView
/// 购物车列表视图

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/cart/unified_cart_list_view.dart';
import '../../controllers/cashier_controller.dart';

class CartListView extends GetView<CashierController> {
  const CartListView({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedCartListView(
      cartItems: controller.cartController.cartItems,
      priceHeaderLabel: '价格(AED)',
      onRemove: controller.cartController.removeFromCart,
      onUpdateQuantity: controller.cartController.updateQuantity,
    );
  }
}
