/// GiftExchangeController
/// 礼品兑换主控制器

import 'package:get/get.dart';
import 'gift_cart_controller.dart';
import 'gift_payment_controller.dart';
import 'gift_product_controller.dart';
import 'gift_category_controller.dart';
import '../models/gift_item.dart';

export 'gift_cart_controller.dart';
export 'gift_payment_controller.dart';
export 'gift_product_controller.dart';
export 'gift_category_controller.dart';

class GiftExchangeController extends GetxController {
  GiftCartController get cartController => Get.find<GiftCartController>();
  GiftPaymentController get paymentController =>
      Get.find<GiftPaymentController>();
  GiftProductController get productController =>
      Get.find<GiftProductController>();
  GiftCategoryController get categoryController =>
      Get.find<GiftCategoryController>();

  @override
  void onInit() {
    super.onInit();
    Get.put(GiftCartController());
    Get.put(GiftPaymentController());
    Get.put(GiftProductController());
    Get.put(GiftCategoryController());
  }

  @override
  void onClose() {
    Get.delete<GiftCartController>();
    Get.delete<GiftPaymentController>();
    Get.delete<GiftProductController>();
    Get.delete<GiftCategoryController>();
    super.onClose();
  }

  List<GiftItem> get filteredGifts {
    return productController.getGiftsByCategory(
      categoryController.selectedCategory.value,
    );
  }

  double get totalAmount => cartController.subtotal;

  void selectCategory(String category) {
    final previousCategory = categoryController.selectedCategory.value;
    if (previousCategory != category) {
      cartController.clearCart();
    }
    categoryController.selectCategory(category);
  }

  Future<void> checkout() async {
    await paymentController.checkout(
      hasItems: cartController.cartItems.isNotEmpty,
      totalAmount: totalAmount,
      onSuccess: () {
        cartController.clearCart();
      },
    );
  }
}
