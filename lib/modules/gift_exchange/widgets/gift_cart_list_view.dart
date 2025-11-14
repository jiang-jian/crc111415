/// GiftCartListView
/// 礼品购物车列表

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/cart/unified_cart_list_view.dart';
import '../controllers/gift_exchange_controller.dart';

class GiftCartListView extends GetView<GiftExchangeController> {
  const GiftCartListView({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedCartListView(
      cartItems: controller.cartController.cartItems,
      priceHeaderLabel: '价格(票)',
      onRemove: controller.cartController.removeFromCart,
      onUpdateQuantity: controller.cartController.updateQuantity,
    );
  }
}
