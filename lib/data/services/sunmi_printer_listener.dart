import 'package:sunmi_flutter_plugin_printer/bean/printer.dart';
import 'package:sunmi_flutter_plugin_printer/listener/printer_listener.dart';
import 'package:get/get.dart';

/// 商米打印机监听器
/// 对应demo中的 MyPrinterListener
class SunmiPrinterListener extends PrinterListener {
  // 存储打印机实例的响应式变量
  final Rx<Printer?> printerInstance = Rx<Printer?>(null);

  @override
  void onDefPrinter(Printer printer) {
    print('[SunmiPrinterListener] 收到打印机实例: ${printer.toJson()}');
    printerInstance.value = printer;
  }
}
