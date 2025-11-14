import 'package:get/get.dart';

class VersionCheckController extends GetxController {
  final deviceId = RxString('');
  final versionInfo = RxString('');
  final updateTime = RxString('');

  @override
  void onInit() {
    super.onInit();
    _loadDeviceInfo();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> _loadDeviceInfo() async {
    deviceId.value = 'test_id';
    versionInfo.value = '1.2.34';
    updateTime.value = '2025-08-01 12:00:00';
  }

  Future<void> checkUpdate() async {
    // TODO: 实现检查更新逻辑
  }
}
