import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../../data/services/nfc_service.dart';
import '../../../data/services/sunmi_printer_service.dart';
import '../../../core/widgets/toast.dart';

/// 设备初始化步骤
enum DeviceSetupStep {
  scanner, // 扫码枪
  cardReader, // 读卡器
  printer, // 打印机
  completed, // 完成
}

/// 设备初始化控制器
class DeviceSetupController extends GetxController {
  // 当前步骤
  final currentStep = DeviceSetupStep.scanner.obs;

  // 步骤完成状态
  final scannerCompleted = false.obs;
  final cardReaderCompleted = false.obs;
  final printerCompleted = false.obs;

  // NFC 服务
  final NfcService nfcService = Get.find<NfcService>();

  // 打印机服务
  final SunmiPrinterService printerService = Get.find<SunmiPrinterService>();

  // NFC 检测状态
  final nfcCheckStatus =
      ''.obs; // 'checking', 'available', 'unavailable', 'disabled'

  // NFC 读卡状态
  final cardReadStatus = ''.obs; // 'waiting', 'reading', 'success', 'failed'

  // 打印机检测状态
  final printerCheckStatus = ''.obs; // 'checking', 'ready', 'error', 'warning'

  // 打印机测试状态
  final printerTestStatus = ''.obs; // 'idle', 'testing', 'success', 'failed'

  // 错误信息
  final errorMessage = ''.obs;

  // 读取到的卡片数据
  final cardData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    // 默认从扫码枪步骤开始
    currentStep.value = DeviceSetupStep.scanner;

    // 监听 NFC 服务的卡片数据变化
    ever(nfcService.cardData, _handleCardDataChange);
  }

  /// 处理卡片数据变化
  void _handleCardDataChange(Map<String, dynamic>? data) {
    if (data != null && currentStep.value == DeviceSetupStep.cardReader) {
      cardData.value = data;
      if (data['isValid'] == true) {
        cardReadStatus.value = 'success';
        cardReaderCompleted.value = true;
      }
    }
  }

  /// 进入读卡器设置步骤
  void enterCardReaderSetup() {
    currentStep.value = DeviceSetupStep.cardReader;
    cardData.value = null;
    cardReadStatus.value = '';
    errorMessage.value = '';
    checkNfcDevice();
  }

  /// 检测 NFC 设备
  Future<void> checkNfcDevice() async {
    try {
      print('[DeviceSetup] 开始检测 NFC 设备');
      nfcCheckStatus.value = 'checking';
      errorMessage.value = '';

      // 检查 NFC 可用性，获取详细状态
      final availability = await nfcService.checkNfcAvailability();
      print('[DeviceSetup] NFC 可用性状态: $availability');

      // 根据不同的可用性状态设置提示
      switch (availability) {
        case NfcAvailability.unsupported:
          nfcCheckStatus.value = 'unsupported';
          errorMessage.value = '当前设备不支持 NFC 功能';
          print('[DeviceSetup] 设备硬件不支持 NFC');
          break;

        case NfcAvailability.disabled:
          nfcCheckStatus.value = 'disabled';
          errorMessage.value = 'NFC 功能未启用，请前往系统设置开启';
          print('[DeviceSetup] NFC 未启用');
          break;

        case NfcAvailability.enabled:
          nfcCheckStatus.value = 'available';
          print('[DeviceSetup] NFC 设备检测完成，可以使用');

          // 自动开始读卡监听
          await Future.delayed(const Duration(milliseconds: 500));
          startReadCard();
          break;
      }
    } catch (e) {
      print('[DeviceSetup] 检测 NFC 设备失败: $e');
      nfcCheckStatus.value = 'unavailable';
      errorMessage.value = '检测 NFC 设备失败: $e';
    }
  }

  /// 打开系统 NFC 设置
  Future<void> openNfcSettings() async {
    try {
      print('[DeviceSetup] 尝试打开 NFC 设置');
      final opened = await nfcService.openNfcSettings();

      if (!opened) {
        // 无法直接打开，引导用户手动打开
        Toast.show(
          message: '请手动打开系统设置 → 连接设置 → NFC，启用后返回重试',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('[DeviceSetup] 打开 NFC 设置失败: $e');
      errorMessage.value = '打开设置失败: $e';
    }
  }

  /// 重新检测 NFC（用户从设置返回后）
  Future<void> recheckNfc() async {
    print('[DeviceSetup] 重新检测 NFC');
    await checkNfcDevice();
  }

  /// 开始读卡
  Future<void> startReadCard() async {
    try {
      print('[DeviceSetup] 开始读卡...');
      cardReadStatus.value = 'reading';
      errorMessage.value = '';
      cardData.value = null;

      final result = await nfcService.readM1Card();
      print('[DeviceSetup] 读卡结果: $result');

      if (result != null && result['isValid'] == true) {
        print('[DeviceSetup] 读卡成功，UID: ${result['uid']}');
        print('[DeviceSetup] 保持在当前页面，不进行任何导航');
        cardData.value = result;
        cardReadStatus.value = 'success';
        cardReaderCompleted.value = true;
        // 关键：读卡成功后不做任何导航操作，停留在当前页面
      } else {
        print('[DeviceSetup] 读卡失败，无效数据');
        cardReadStatus.value = 'failed';
        errorMessage.value = '等待中，请放置卡片进行读卡操作';
      }
    } catch (e) {
      print('[DeviceSetup] 读卡异常: $e');
      cardReadStatus.value = 'failed';
      errorMessage.value = '读卡失败: $e';
    }
  }

  /// 重试读卡
  void retryReadCard() {
    print('[DeviceSetup] 重试读卡');
    cardReadStatus.value = 'waiting';
    errorMessage.value = '';
    cardData.value = null;
    startReadCard();
  }

  /// 进入打印机设置步骤
  void enterPrinterSetup() {
    currentStep.value = DeviceSetupStep.printer;
    printerCheckStatus.value = '';
    printerTestStatus.value = 'idle';
    errorMessage.value = '';
    checkPrinterStatus();
  }

  /// 检测打印机状态
  Future<void> checkPrinterStatus() async {
    try {
      print('[DeviceSetup] 开始检测打印机状态');
      printerCheckStatus.value = 'checking';
      errorMessage.value = '';

      final statusInfo = await printerService.getPrinterStatus();
      print('[DeviceSetup] 打印机状态: ${statusInfo.rawStatus}');

      switch (statusInfo.status) {
        case PrinterStatus.ready:
          printerCheckStatus.value = 'ready';
          print('[DeviceSetup] 打印机就绪');
          break;
        case PrinterStatus.error:
          printerCheckStatus.value = 'error';
          errorMessage.value = statusInfo.message;
          print('[DeviceSetup] 打印机错误: ${statusInfo.message}');
          break;
        case PrinterStatus.warning:
          printerCheckStatus.value = 'warning';
          errorMessage.value = statusInfo.message;
          print('[DeviceSetup] 打印机警告: ${statusInfo.message}');
          break;
        case PrinterStatus.unknown:
          printerCheckStatus.value = 'error';
          errorMessage.value = '未检测到打印机';
          print('[DeviceSetup] 打印机状态未知');
          break;
      }
    } catch (e) {
      print('[DeviceSetup] 检测打印机失败: $e');
      printerCheckStatus.value = 'error';
      errorMessage.value = '检测打印机失败: $e';
    }
  }

  /// 测试打印热敏小票
  Future<void> testPrintReceipt() async {
    try {
      print('[DeviceSetup] 开始测试打印');
      printerTestStatus.value = 'testing';
      errorMessage.value = '';

      final success = await printerService.testPrintReceipt();

      if (success) {
        print('[DeviceSetup] 测试打印成功');
        printerTestStatus.value = 'success';
        printerCompleted.value = true;
        Toast.success(message: '打印测试通过！');
      } else {
        print('[DeviceSetup] 测试打印失败');
        printerTestStatus.value = 'failed';
        errorMessage.value = '测试打印失败，请检查打印机';
        Toast.error(message: '测试打印失败，请检查打印机');
      }
    } catch (e) {
      print('[DeviceSetup] 测试打印异常: $e');
      printerTestStatus.value = 'failed';
      errorMessage.value = '测试打印失败: $e';
      Toast.error(message: '测试打印失败: $e');
    }
  }

  /// 下一步
  void nextStep() {
    switch (currentStep.value) {
      case DeviceSetupStep.scanner:
        if (scannerCompleted.value) {
          enterCardReaderSetup();
        }
        break;
      case DeviceSetupStep.cardReader:
        if (cardReaderCompleted.value) {
          enterPrinterSetup();
        }
        break;
      case DeviceSetupStep.printer:
        if (printerCompleted.value) {
          currentStep.value = DeviceSetupStep.completed;
          completeSetup();
        }
        break;
      case DeviceSetupStep.completed:
        break;
    }
  }

  /// 上一步
  void previousStep() async {
    // 如果当前在读卡器步骤，先停止读卡
    if (currentStep.value == DeviceSetupStep.cardReader) {
      print('[DeviceSetup] 离开读卡器步骤，停止NFC会话');
      await nfcService.stopReading();
    }

    switch (currentStep.value) {
      case DeviceSetupStep.scanner:
        break;
      case DeviceSetupStep.cardReader:
        currentStep.value = DeviceSetupStep.scanner;
        break;
      case DeviceSetupStep.printer:
        currentStep.value = DeviceSetupStep.cardReader;
        break;
      case DeviceSetupStep.completed:
        currentStep.value = DeviceSetupStep.printer;
        break;
    }
  }

  /// 完成设置
  void completeSetup() {
    // 切换到完成页面
    currentStep.value = DeviceSetupStep.completed;
  }

  /// 跳过当前步骤
  void skipCurrentStep() async {
    // 如果在读卡器步骤，先停止读卡
    if (currentStep.value == DeviceSetupStep.cardReader) {
      print('[DeviceSetup] 跳过读卡器步骤，停止NFC会话');
      await nfcService.stopReading();
    }
    switch (currentStep.value) {
      case DeviceSetupStep.scanner:
        scannerCompleted.value = true;
        break;
      case DeviceSetupStep.cardReader:
        cardReaderCompleted.value = true;
        break;
      case DeviceSetupStep.printer:
        printerCompleted.value = true;
        break;
      case DeviceSetupStep.completed:
        break;
    }
    nextStep();
  }

  @override
  void onClose() {
    print('[DeviceSetup] Controller 关闭，停止NFC会话');
    nfcService.stopReading();
    super.onClose();
  }

  /// 清理读卡器步骤状态
  void cleanupCardReaderStep() async {
    print('[DeviceSetup] 清理读卡器步骤状态');
    await nfcService.stopReading();
    cardReadStatus.value = '';
    cardData.value = null;
    errorMessage.value = '';
  }

  /// 清理打印机步骤状态
  void cleanupPrinterStep() {
    print('[DeviceSetup] 清理打印机步骤状态');
    printerCheckStatus.value = '';
    printerTestStatus.value = 'idle';
    errorMessage.value = '';
  }

  /// 测试打印机功能（完整链路测试）
  /// 用于验证需求：集成SDK -> 获取状态 -> 测试打印
  Future<Map<String, dynamic>> testPrinterFullChain() async {
    print('\n[DeviceSetup] ========== 打印机完整链路测试 ==========\n');

    final results = <String, dynamic>{
      'timestamp': DateTime.now().toString(),
      'steps': <String, dynamic>{},
    };

    // 步骤 1: 集成 SDK（检查打印机服务是否可用）
    print('[DeviceSetup] 步骤 1: 检查 Sunmi 打印机 SDK 集成...');
    try {
      final isAvailable = printerService.isPrinterAvailable.value;
      results['steps']['sdk_integration'] = {
        'success': isAvailable,
        'message': isAvailable ? 'SDK 集成成功' : 'SDK 不可用',
      };
      print('[DeviceSetup] ${isAvailable ? "✓ SDK 集成成功" : "✗ SDK 不可用"}');
    } catch (e) {
      results['steps']['sdk_integration'] = {
        'success': false,
        'error': e.toString(),
      };
      print('[DeviceSetup] ✗ SDK 集成测试失败: $e');
    }

    // 步骤 2: 获取打印机实时状态
    print('\n[DeviceSetup] 步骤 2: 获取打印机实时状态...');
    try {
      final statusInfo = await printerService.getPrinterStatus();
      results['steps']['status_check'] = {
        'success': true,
        'status': statusInfo.status.toString(),
        'rawStatus': statusInfo.rawStatus,
        'message': statusInfo.message,
      };
      print('[DeviceSetup] ✓ 状态获取成功');
      print('[DeviceSetup]   状态: ${statusInfo.rawStatus}');
      print('[DeviceSetup]   信息: ${statusInfo.message}');
    } catch (e) {
      results['steps']['status_check'] = {
        'success': false,
        'error': e.toString(),
      };
      print('[DeviceSetup] ✗ 状态获取失败: $e');
    }

    // 步骤 3: 测试打印功能（打印固定文本："打印热敏小票测试"）
    print('\n[DeviceSetup] 步骤 3: 测试打印热敏小票...');
    try {
      final success = await printerService.testPrintReceipt();
      results['steps']['test_print'] = {
        'success': success,
        'message': success ? '打印测试成功' : '打印测试失败',
        'content': '打印热敏小票测试',
      };
      print('[DeviceSetup] ${success ? "✓ 打印测试成功" : "✗ 打印测试失败"}');
      if (success) {
        print('[DeviceSetup]   已打印内容: 打印热敏小票测试');
      }
    } catch (e) {
      results['steps']['test_print'] = {
        'success': false,
        'error': e.toString(),
      };
      print('[DeviceSetup] ✗ 打印测试失败: $e');
    }

    // 统计结果
    final steps = results['steps'] as Map<String, dynamic>;
    final successCount = steps.values
        .where((step) => step['success'] == true)
        .length;
    final totalCount = steps.length;

    results['summary'] = {
      'total': totalCount,
      'success': successCount,
      'failed': totalCount - successCount,
      'allPassed': successCount == totalCount,
    };

    print('\n[DeviceSetup] ========== 测试结果摘要 ==========');
    print('[DeviceSetup] 总步骤: $totalCount');
    print('[DeviceSetup] 成功: $successCount');
    print('[DeviceSetup] 失败: ${totalCount - successCount}');
    print(
      '[DeviceSetup] ${results['summary']['allPassed'] ? "✓ 所有测试通过" : "✗ 部分测试失败"}',
    );
    print('[DeviceSetup] =========================================\n');

    return results;
  }
}
