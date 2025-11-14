/// GiftCategoryController
/// 礼品分类导航管理

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/common_menu.dart';

class GiftCategoryController extends GetxController {
  final selectedCategory = 'gift_exchange'.obs;

  static const List<MenuItem> menuItems = [
    MenuItem(key: 'gift_exchange', label: '礼品兑换', icon: Icons.card_giftcard),
    MenuItem(key: 'exchange_history', label: '兑换记录', icon: Icons.history),
  ];

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
