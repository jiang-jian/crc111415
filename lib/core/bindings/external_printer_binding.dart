import 'package:get/get.dart';
import '../../data/services/external_printer_service.dart';

/// 外接打印机服务绑定
/// 用于在应用启动时初始化外接打印机服务
class ExternalPrinterBinding extends Bindings {
  @override
  void dependencies() {
    // 注册并初始化外接打印机服务
    Get.putAsync(() => ExternalPrinterService().init());
  }
}
