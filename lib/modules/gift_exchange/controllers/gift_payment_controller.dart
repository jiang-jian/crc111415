/// GiftPaymentController
/// 礼品兑换支付管理 - 仅支持彩票支付

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/toast.dart';

class GiftPaymentController extends GetxController {
  final isCheckingOut = false.obs;
  final lotteryBalance = 1500.0.obs;

  @override
  void onInit() {
    super.onInit();
    // 模拟获取彩票余额
    _fetchLotteryBalance();
  }

  Future<void> _fetchLotteryBalance() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final random = Random();
    lotteryBalance.value = random.nextDouble() * 2000 + 500;
  }

  Future<bool> checkout({
    required bool hasItems,
    required double totalAmount,
    required VoidCallback onSuccess,
  }) async {
    if (!hasItems) {
      Toast.show(message: '请先选择礼品');
      return false;
    }

    if (lotteryBalance.value < totalAmount) {
      Toast.error(message: '彩票余额不足，请充值');
      return false;
    }

    isCheckingOut.value = true;

    try {
      await Future.delayed(const Duration(seconds: 2));

      // 扣除余额
      lotteryBalance.value -= totalAmount;

      isCheckingOut.value = false;

      Toast.success(message: '兑换完成');

      onSuccess();
      return true;
    } catch (e) {
      isCheckingOut.value = false;
      Toast.error(message: '兑换失败，请重试');
      return false;
    }
  }

  void refreshBalance() {
    _fetchLotteryBalance();
  }
}
