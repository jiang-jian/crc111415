/// GiftCategoryMenu
/// 礼品分类菜单

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/widgets/common_menu.dart';
import '../controllers/gift_exchange_controller.dart';

class GiftCategoryMenu extends StatelessWidget {
  const GiftCategoryMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GiftExchangeController>();

    return Obx(() {
      final selectedCategory =
          controller.categoryController.selectedCategory.value;

      return CommonMenu(
        menuItems: GiftCategoryController.menuItems,
        selectedKey: selectedCategory,
        onItemSelected: (key) => controller.selectCategory(key),
        width: 200.w,
      );
    });
  }
}
