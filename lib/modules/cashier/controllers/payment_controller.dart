/// PaymentController
/// 支付方式管理

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/toast.dart';

enum PaymentMethod { card, cash }

/// 支付方式配置项
class PaymentMethodConfig {
  final PaymentMethod method;
  final bool enabled;
  final bool isDefault;

  const PaymentMethodConfig({
    required this.method,
    this.enabled = true,
    this.isDefault = false,
  });
}

class PaymentController extends GetxController {
  final selectedPaymentMethod = Rx<PaymentMethod?>(null);
  final isCheckingOut = false.obs;

  final _random = Random();
  late final double _discountAmount;
  late final double _packageDiscountAmount;
  late final double _couponAmount;

  // 支付方式配置(可从接口获取后更新)
  final paymentMethodConfigs = <PaymentMethodConfig>[
    const PaymentMethodConfig(
      method: PaymentMethod.card,
      enabled: true,
      isDefault: true,
    ),
    const PaymentMethodConfig(
      method: PaymentMethod.cash,
      enabled: true,
      isDefault: false,
    ),
  ].obs;

  // 获取启用的支付方式列表
  List<PaymentMethodConfig> get enabledPaymentMethods {
    return paymentMethodConfigs.where((config) => config.enabled).toList();
  }

  // 获取默认支付方式
  PaymentMethod? get defaultPaymentMethod {
    try {
      final defaultConfig = paymentMethodConfigs.firstWhere(
        (config) => config.enabled && config.isDefault,
      );
      return defaultConfig.method;
    } catch (e) {
      return enabledPaymentMethods.isNotEmpty
          ? enabledPaymentMethods.first.method
          : null;
    }
  }

  double get discountAmount => _discountAmount;
  double get packageDiscountAmount => _packageDiscountAmount;
  double get couponAmount => _couponAmount;

  double get totalDiscount {
    return discountAmount + packageDiscountAmount + couponAmount;
  }

  @override
  void onInit() {
    super.onInit();
    _discountAmount = _random.nextDouble() * 50;
    _packageDiscountAmount = _random.nextDouble() * 50;
    _couponAmount = _random.nextDouble() * 50;

    selectedPaymentMethod.value = defaultPaymentMethod;
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> checkout({
    required bool hasItems,
    required VoidCallback onSuccess,
  }) async {
    if (!hasItems) {
      Toast.show(message: '请先选择商品');
      return;
    }

    if (selectedPaymentMethod.value == null) {
      Toast.show(message: '请选择支付方式');
      return;
    }

    isCheckingOut.value = true;

    try {
      await Future.delayed(const Duration(seconds: 2));

      isCheckingOut.value = false;

      Toast.success(message: '收银完成');

      onSuccess();
      selectedPaymentMethod.value = null;
    } catch (e) {
      isCheckingOut.value = false;
      Toast.error(message: '收银失败,请重试');
    }
  }
}
