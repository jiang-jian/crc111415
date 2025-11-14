/// CustomerCenterController
/// 顾客中心管理

import 'package:get/get.dart';
import 'customer_menu_controller.dart';

class CustomerCenterController extends GetxController {
  late final CustomerMenuController menuController;

  @override
  void onInit() {
    super.onInit();
    menuController = Get.put(CustomerMenuController());
  }

  @override
  void onClose() {
    Get.delete<CustomerMenuController>();
    super.onClose();
  }

  void selectMenu(String menuKey) {
    menuController.selectMenu(menuKey);
  }
}
