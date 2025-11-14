/// CartController
/// 购物车状态管理

import '../../../shared/controllers/base_cart_controller.dart';
import '../models/package_item.dart';

class CartController extends BaseCartController {
  void addToCart(PackageItem package) {
    addToCartFromItem(
      id: package.id,
      name: package.name,
      price: package.price,
      stock: package.stock,
    );
  }
}
