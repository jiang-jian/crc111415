import 'package:get/get.dart';
import 'package:ailand_pos/data/services/sunmi_customer_api_service.dart';

class SunmiCustomerApiController extends GetxController {
  final SunmiCustomerApiService _apiService = SunmiCustomerApiService();

  final isConnected = false.obs;
  final statusMessage = '未初始化'.obs;
  final deviceInfo = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    initializeService();
  }

  /// 初始化服务
  Future<void> initializeService() async {
    statusMessage.value = '检查服务安装状态...';

    final isInstalled = await _apiService.checkServiceInstalled();

    if (!isInstalled) {
      isConnected.value = false;
      statusMessage.value = '失败: SunmiCustomerService 未安装';
      return;
    }

    statusMessage.value = '服务已安装，正在连接...';

    final success = await _apiService.initialize();
    final connected = await _apiService.isConnected();

    isConnected.value = connected;
    statusMessage.value = success ? '初始化成功' : '初始化失败（连接超时）';

    if (success) {
      loadDeviceInfo();
    }
  }

  /// 加载设备信息
  Future<void> loadDeviceInfo() async {
    final info = await _apiService.getDeviceInfo();
    deviceInfo.value = info;
  }

  /// 启用移动网络
  Future<bool> enableMobileNetwork({int slotIndex = 0}) async {
    return await _apiService.enableMobileNetwork(slotIndex: slotIndex);
  }

  /// 禁用移动网络
  Future<bool> disableMobileNetwork({int slotIndex = 0}) async {
    return await _apiService.disableMobileNetwork(slotIndex: slotIndex);
  }

  /// 打印设备信息
  Future<void> printDeviceInfo() async {
    await _apiService.printDeviceInfo();
  }
}
