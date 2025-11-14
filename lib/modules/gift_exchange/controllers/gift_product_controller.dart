/// GiftProductController
/// 礼品商品数据管理

import 'package:get/get.dart';
import '../models/gift_item.dart';

class GiftProductController extends GetxController {
  final giftItems = <GiftItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadGiftItems();
  }

  void _loadGiftItems() {
    giftItems.value = [
      GiftItem(
        id: 'gift_1',
        name: '泰迪熊玩偶',
        description: '可爱的泰迪熊，高度30cm',
        price: 50.0,
        category: 'gift_exchange',
        stock: 10,
        specification: '30cm',
      ),
      GiftItem(
        id: 'gift_2',
        name: '乐高积木套装',
        description: '城市系列，适合6岁以上',
        price: 120.0,
        category: 'gift_exchange',
        stock: 5,
      ),
      GiftItem(
        id: 'gift_3',
        name: '迪士尼水杯',
        description: '米奇图案保温杯',
        price: 30.0,
        category: 'gift_exchange',
        stock: 20,
        specification: '500ml',
      ),
      GiftItem(
        id: 'gift_4',
        name: '拼图玩具',
        description: '1000片风景拼图',
        price: 40.0,
        category: 'gift_exchange',
        stock: 0,
        isSoldOut: true,
      ),
      GiftItem(
        id: 'gift_5',
        name: '遥控汽车',
        description: '1:18比例遥控赛车',
        price: 80.0,
        category: 'gift_exchange',
        stock: 8,
      ),
      GiftItem(
        id: 'gift_6',
        name: '儿童书包',
        description: '卡通图案双肩包',
        price: 60.0,
        category: 'gift_exchange',
        stock: 15,
      ),
    ];
  }

  List<GiftItem> getGiftsByCategory(String category) {
    if (category == 'exchange_history') {
      return [];
    }
    return giftItems.where((item) => item.category == category).toList();
  }
}
