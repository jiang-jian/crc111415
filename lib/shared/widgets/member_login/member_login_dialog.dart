/// MemberLoginDialog
/// 会员登录对话框，使用通用 CardScanDialog 组件
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/card_scan_dialog.dart';
import 'member_login_controller.dart';
import 'member_registration_dialog.dart';

class MemberLoginDialog {
  /// 显示登录对话框(带注册会员按钮)
  static Future<void> show(BuildContext context) async {
    final controller = Get.find<MemberLoginController>();

    final cardNumber = await CardScanDialog.show(
      context: context,
      onCardScanned: () async {
        await controller.simulateCardLogin();
        return 'SUCCESS';
      },
      onRegister: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MemberRegistrationDialog(),
        );
      },
    );

    if (cardNumber != null) {
      // 刷卡成功,登录完成
    }
  }

  /// 快速登录对话框(自动关闭,无注册按钮)
  /// 返回登录是否成功
  static Future<bool> showQuick(BuildContext context) async {
    final memberController = Get.isRegistered<MemberLoginController>()
        ? Get.find<MemberLoginController>()
        : Get.put(MemberLoginController());

    if (memberController.isLoggedIn.value) {
      return true;
    }

    final cardNumber = await CardScanDialog.show(
      context: context,
      onCardScanned: () async {
        await memberController.simulateCardLogin();
        return 'SUCCESS';
      },
    );

    return cardNumber != null && memberController.isLoggedIn.value;
  }
}
