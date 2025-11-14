import 'package:get/get.dart';
import '../../network_check/controllers/network_check_controller.dart';
import '../../../data/services/external_card_reader_service.dart';
import 'version_check_controller.dart';

class SettingsController extends GetxController {
  final selectedMenu = RxString('external_card_reader');

  void selectMenu(String menu) {
    selectedMenu.value = menu;
  }

  @override
  void onClose() {
    print('onclose settings');
    _cleanupNetworkCheckController();
    _cleanupVersionCheckController();
    _cleanupExternalCardReaderService();
    super.onClose();
  }

  /// 清理 NetworkCheckController
  void _cleanupNetworkCheckController() {
    if (Get.isRegistered<NetworkCheckController>()) {
      Get.delete<NetworkCheckController>(force: true);
      print('✓ 清理 NetworkCheckController（设置页）');
    }
  }

  /// 清理 VersionCheckController
  void _cleanupVersionCheckController() {
    if (Get.isRegistered<VersionCheckController>()) {
      Get.delete<VersionCheckController>(force: true);
      print('✓ 清理 VersionCheckController（设置页）');
    }
  }

  /// 清理 ExternalCardReaderService
  void _cleanupExternalCardReaderService() {
    if (Get.isRegistered<ExternalCardReaderService>()) {
      final service = Get.find<ExternalCardReaderService>();
      service.onClose();
    }
  }
}
