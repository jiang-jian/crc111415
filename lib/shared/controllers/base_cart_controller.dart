/// BaseCartController
/// 通用购物车状态管理基类

import 'package:get/get.dart';
import '../../modules/cashier/models/cart_item.dart';

class BaseCartController extends GetxController {
  final cartItems = <CartItem>[].obs;

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// 通用添加到购物车方法
  void addToCartFromItem({
    required String id,
    required String name,
    required double price,
    int? stock,
  }) {
    if (stock != null && stock == 0) return;

    final index = cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(id: id, name: name, price: price));
    }
  }

  void removeFromCart(String itemId) {
    cartItems.removeWhere((item) => item.id == itemId);
  }

  void updateQuantity(String itemId, int delta) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      cartItems[index].quantity += delta;
      if (cartItems[index].quantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems.refresh();
      }
    }
  }

  void clearCart() {
    cartItems.clear();
  }
}
