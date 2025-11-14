/// CategoryController
/// 分类导航管理

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/common_menu.dart';

class CategoryController extends GetxController {
  final selectedCategory = 'game_coin_package'.obs;
  final expandedCategories = <String>{'game_coins'}.obs;

  // 菜单配置（统一管理,避免重复定义）
  static const List<MenuItem> menuItems = [
    MenuItem(
      key: 'game_coins',
      label: '游戏币',
      icon: Icons.monetization_on_outlined,
      children: [
        MenuItem(key: 'game_coin_package', label: '游戏币套餐', icon: Icons.circle),
        MenuItem(key: 'super_coin_package', label: '超级币套餐', icon: Icons.circle),
      ],
    ),
    MenuItem(
      key: 'vouchers',
      label: '兑换券',
      icon: Icons.card_giftcard_outlined,
      children: [
        MenuItem(key: 'promotion', label: '引流', icon: Icons.circle),
        MenuItem(key: 'machine_exchange', label: '机台兑币', icon: Icons.circle),
        MenuItem(key: 'scratch_card', label: '刮刮卡', icon: Icons.circle),
        MenuItem(key: 'marketing_activity', label: '市场活动', icon: Icons.circle),
      ],
    ),
    MenuItem(
      key: 'retail',
      label: '零售商品',
      icon: Icons.shopping_bag_outlined,
      children: [
        MenuItem(key: 'snacks', label: '小食品', icon: Icons.circle),
        MenuItem(key: 'beverages', label: '饮料', icon: Icons.circle),
      ],
    ),
    MenuItem(key: 'sign_coin', label: '签币', icon: Icons.edit_note_outlined),
  ];

  // 从菜单配置中动态获取分类的父级
  String? getCategoryParent(String category) {
    for (final item in menuItems) {
      if (item.children != null) {
        for (final child in item.children!) {
          if (child.key == category) {
            return item.key;
          }
        }
      }
    }
    return null;
  }

  void selectCategory(String category, {required VoidCallback onClearCart}) {
    final currentParent = getCategoryParent(selectedCategory.value);
    final newParent = getCategoryParent(category);

    if (selectedCategory.value != category) {
      if (currentParent != 'retail' || newParent != 'retail') {
        onClearCart();
      }
    }

    selectedCategory.value = category;
  }

  void toggleCategory(String category) {
    if (expandedCategories.contains(category)) {
      expandedCategories.remove(category);
    } else {
      expandedCategories.add(category);
    }
  }
}
