/// GiftTotalAmountBar
/// 礼品兑换总计金额栏

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/cart/base_total_amount_bar.dart';
import '../controllers/gift_exchange_controller.dart';

class GiftTotalAmountBar extends GetView<GiftExchangeController> {
  const GiftTotalAmountBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subtotal = controller.cartController.subtotal;
      final totalAmount = controller.totalAmount;
      final hasItems = controller.cartController.cartItems.isNotEmpty;

      return BaseTotalAmountBar(
        subtotal: subtotal,
        totalAmount: totalAmount,
        hasItems: hasItems,
        currency: '票',
      );
    });
  }
}
