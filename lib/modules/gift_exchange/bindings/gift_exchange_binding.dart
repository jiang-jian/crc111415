/// GiftExchangeBinding
/// 礼品兑换页面绑定

import 'package:get/get.dart';
import '../controllers/gift_exchange_controller.dart';

class GiftExchangeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftExchangeController>(() => GiftExchangeController());
  }
}
