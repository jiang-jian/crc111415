import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/common_menu.dart';
import '../../controllers/cashier_controller.dart';

class CategoryAccordion extends StatelessWidget {
  const CategoryAccordion({super.key});

  @override
  Widget build(BuildContext context) {
    final cashierController = Get.find<CashierController>();

    return Obx(
      () => CommonMenu(
        menuItems: CategoryController.menuItems,
        selectedKey:
            cashierController.categoryController.selectedCategory.value,
        onItemSelected: (key) {
          cashierController.selectCategory(key);
        },
        width: 200.w,
      ),
    );
  }
}
