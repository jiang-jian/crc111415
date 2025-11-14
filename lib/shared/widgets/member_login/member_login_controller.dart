/// MemberLoginController
/// 会员登录控制器，管理会员登录状态和交互逻辑
import 'package:get/get.dart';

class MemberLoginController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxString memberName = ''.obs;
  final RxString memberPhone = ''.obs;
  final RxString cardNumber = ''.obs;

  /// 模拟刷卡登录
  Future<void> simulateCardLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    memberName.value = '张三';
    memberPhone.value = '138****5678';
    isLoggedIn.value = true;
  }

  /// 模拟读卡
  Future<void> simulateReadCard() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    cardNumber.value = 'CARD${DateTime.now().millisecondsSinceEpoch % 100000}';
  }

  /// 登出
  void logout() {
    isLoggedIn.value = false;
    memberName.value = '';
    memberPhone.value = '';
    cardNumber.value = '';
  }

  /// 重置卡号
  void resetCardNumber() {
    cardNumber.value = '';
  }
}
