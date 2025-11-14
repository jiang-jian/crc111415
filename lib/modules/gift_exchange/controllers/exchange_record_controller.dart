/// ExchangeRecordController
/// 兑换记录控制器

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/exchange_record.dart';
import '../../../core/widgets/toast.dart';

enum PaymentType { lottery, gameCoin }

class ExchangeRecordController extends GetxController {
  // 搜索条件
  final phoneNumber = ''.obs;
  final orderNumber = ''.obs;
  final dateRange = Rx<DateTimeRange?>(null);

  // 支付类型选择
  final selectedPaymentType = PaymentType.lottery.obs;

  // 分页
  final currentPage = 1.obs;
  final pageSize = 10.obs;
  final totalCount = 0.obs;

  // 数据加载
  final isLoading = false.obs;
  final records = <ExchangeRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  /// 更新手机号
  void updatePhoneNumber(String value) {
    phoneNumber.value = value;
  }

  /// 更新订单编号
  void updateOrderNumber(String value) {
    orderNumber.value = value;
  }

  /// 更新日期范围
  void updateDateRange(DateTimeRange? range) {
    dateRange.value = range;
  }

  /// 切换支付类型
  void selectPaymentType(PaymentType type) {
    selectedPaymentType.value = type;
    currentPage.value = 1;
    loadRecords();
  }

  /// 查询
  Future<void> search() async {
    currentPage.value = 1;
    await loadRecords();
  }

  /// 重置搜索条件
  void resetSearch() {
    phoneNumber.value = '';
    orderNumber.value = '';
    dateRange.value = null;
    currentPage.value = 1;
    loadRecords();
  }

  /// 加载记录
  Future<void> loadRecords() async {
    isLoading.value = true;

    try {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(milliseconds: 800));

      // 模拟数据
      final mockRecords = _generateMockRecords();
      records.value = mockRecords;
      totalCount.value = 50; // 模拟总数
    } catch (e) {
      Toast.error(message: '加载数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 翻页
  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages) return;
    currentPage.value = page;
    await loadRecords();
  }

  /// 总页数
  int get totalPages => (totalCount.value / pageSize.value).ceil();

  /// 生成模拟数据
  List<ExchangeRecord> _generateMockRecords() {
    final paymentMethod = selectedPaymentType.value == PaymentType.lottery
        ? '彩票支付'
        : '游戏币支付';

    return List.generate(pageSize.value, (index) {
      final recordIndex = (currentPage.value - 1) * pageSize.value + index + 1;
      return ExchangeRecord(
        id: 'EX${DateTime.now().millisecondsSinceEpoch + index}',
        time: DateTime.now().subtract(Duration(hours: index)),
        orderNumber: 'ORD${20250000 + recordIndex}',
        memberLevel: ['普通会员', 'VIP会员', '至尊会员'][index % 3],
        orderStatus: ['已完成', '待处理', '已取消'][index % 3],
        memberPhone: '138****${(1000 + recordIndex).toString().substring(1)}',
        paymentMethod: paymentMethod,
        amount: (index + 1) * 10.0 + (index % 5) * 0.5,
        cashier: '收银员${(index % 3) + 1}',
        remark: index % 3 == 0 ? '礼品兑换' : null,
      );
    });
  }
}
