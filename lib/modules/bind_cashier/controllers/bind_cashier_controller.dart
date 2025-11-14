import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/toast.dart';
import '../views/bind_cashier_review_page.dart';

class BindCashierController extends GetxController {
  late TextEditingController deviceIdController;
  final selectedType = Rx<String?>(null);
  final List<String> typeOptions = ['收银台', '自助机', '其他'];
  BuildContext? _context;

  @override
  void onInit() {
    super.onInit();
    // Mock 自动获取设备ID
    deviceIdController = TextEditingController(text: 'DEVICE_20241104_001');
  }

  @override
  void onClose() {
    deviceIdController.dispose();
    super.onClose();
  }

  void handleSubmit() {
    final deviceId = deviceIdController.text.trim();

    if (selectedType.value == null) {
      Toast.error(message: '请选择点位类型');
      return;
    }

    // TODO: 实际提交逻辑
    print('提交绑定 - 设备ID: $deviceId, 点位类型: ${selectedType.value}');

    // 显示提交成功提示
    Toast.success(message: '绑定申请已提交');

    // 延迟后跳转到审核页面
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(_context!).push(
        MaterialPageRoute(builder: (context) => const BindCashierReviewPage()),
      );
    });
  }

  void setContext(BuildContext context) {
    _context = context;
  }
}
