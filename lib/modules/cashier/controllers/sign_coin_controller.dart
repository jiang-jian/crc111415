/// SignCoinController
/// 签币功能状态管理

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/toast.dart';

class SignCoinPerson {
  final String id;
  final String name;
  final String password;

  const SignCoinPerson({
    required this.id,
    required this.name,
    required this.password,
  });
}

class SignCoinController extends GetxController {
  final selectedPersonId = Rx<String?>(null);
  final selectedReason = Rx<String?>(null);
  final quantity = ''.obs;
  final remark = ''.obs;

  // Mock 签币人员数据
  final List<SignCoinPerson> persons = [
    const SignCoinPerson(id: '1', name: '张经理', password: '123456'),
    const SignCoinPerson(id: '2', name: '李主管', password: '123456'),
    const SignCoinPerson(id: '3', name: '王店长', password: '123456'),
    const SignCoinPerson(id: '4', name: '赵总监', password: '123456'),
  ];

  // 签增原因选项
  final List<String> reasons = ['干部签送', '客户赔偿', '系统故障', '营销活动', '会员补偿', '设备维护'];

  void selectPerson(String? personId) {
    selectedPersonId.value = personId;
  }

  void selectReason(String? reason) {
    selectedReason.value = reason;
  }

  void updateQuantity(String value) {
    quantity.value = value;
  }

  void updateRemark(String value) {
    remark.value = value;
  }

  bool get isFormValid {
    return selectedPersonId.value != null &&
        selectedReason.value != null &&
        quantity.value.isNotEmpty &&
        int.tryParse(quantity.value) != null &&
        int.parse(quantity.value) > 0;
  }

  SignCoinPerson? get selectedPerson {
    if (selectedPersonId.value == null) return null;
    return persons.firstWhereOrNull((p) => p.id == selectedPersonId.value);
  }

  bool verifyPassword(String password) {
    final person = selectedPerson;
    if (person == null) return false;
    return person.password == password;
  }

  void reset() {
    selectedPersonId.value = null;
    selectedReason.value = null;
    quantity.value = '';
    remark.value = '';
  }

  Future<void> confirmSignCoin(BuildContext context) async {
    // 模拟签币操作
    await Future.delayed(const Duration(milliseconds: 500));

    // 显示成功提示
    if (context.mounted) {
      Toast.success(
        message: '已为 ${selectedPerson?.name ?? ''} 签增 ${quantity.value} 游戏币',
      );
    }

    // 清空数据
    reset();
  }
}
