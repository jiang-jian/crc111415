/// GiftCartController
/// 礼品购物车状态管理

import '../../../shared/controllers/base_cart_controller.dart';
import '../models/gift_item.dart';

class GiftCartController extends BaseCartController {
  void addToCart(GiftItem gift) {
    addToCartFromItem(
      id: gift.id,
      name: gift.name,
      price: gift.price,
      stock: gift.stock,
    );
  }
}
