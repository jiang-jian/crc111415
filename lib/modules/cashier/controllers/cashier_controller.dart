/// CashierController
/// 收银台状态协调管理

import 'package:get/get.dart';
import 'cart_controller.dart';
import 'payment_controller.dart';
import 'package_controller.dart';
import 'category_controller.dart';
import 'sign_coin_controller.dart';
import '../models/package_item.dart';

export 'cart_controller.dart';
export 'payment_controller.dart';
export 'package_controller.dart';
export 'category_controller.dart';
export 'sign_coin_controller.dart';

class CashierController extends GetxController {
  CartController get cartController => Get.find<CartController>();
  PaymentController get paymentController => Get.find<PaymentController>();
  PackageController get packageController => Get.find<PackageController>();
  CategoryController get categoryController => Get.find<CategoryController>();
  SignCoinController get signCoinController => Get.find<SignCoinController>();

  @override
  void onInit() {
    super.onInit();
    Get.put(CartController());
    Get.put(PaymentController());
    Get.put(PackageController());
    Get.put(CategoryController());
    Get.put(SignCoinController());
  }

  @override
  void onClose() {
    Get.delete<CartController>();
    Get.delete<PaymentController>();
    Get.delete<PackageController>();
    Get.delete<CategoryController>();
    Get.delete<SignCoinController>();
    super.onClose();
  }

  // 便捷方法:获取当前分类的商品列表
  List<PackageItem> get filteredPackages {
    return packageController.getPackagesByCategory(
      categoryController.selectedCategory.value,
    );
  }

  // 便捷方法:计算总金额
  double get totalAmount {
    final amount = cartController.subtotal - paymentController.totalDiscount;
    return amount > 0 ? amount : 0;
  }

  // 便捷方法:选择分类
  void selectCategory(String category) {
    categoryController.selectCategory(
      category,
      onClearCart: cartController.clearCart,
    );
  }

  // 便捷方法:结账
  Future<void> checkout() async {
    await paymentController.checkout(
      hasItems: cartController.cartItems.isNotEmpty,
      onSuccess: () {
        cartController.clearCart();
      },
    );
  }
}
