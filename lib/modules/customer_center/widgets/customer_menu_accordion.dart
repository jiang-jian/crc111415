import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/widgets/common_menu.dart';
import '../controllers/customer_center_controller.dart';
import '../controllers/customer_menu_controller.dart';

class CustomerMenuAccordion extends StatelessWidget {
  const CustomerMenuAccordion({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerCenterController>();

    return Obx(
      () => CommonMenu(
        menuItems: CustomerMenuController.menuItems,
        selectedKey: controller.menuController.selectedMenu.value,
        onItemSelected: (key) {
          controller.selectMenu(key);
        },
        width: 200.w,
      ),
    );
  }
}
