import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_message.dart';

class NotificationCenterController extends GetxController {
  // 消息列表
  final RxList<NotificationMessage> messages = <NotificationMessage>[].obs;

  // 是否正在加载
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
    print('NotificationCenterController onInit');
  }

  /// 加载消息列表
  Future<void> loadMessages() async {
    isLoading.value = true;
    try {
      // 模拟网络请求
      await Future.delayed(const Duration(milliseconds: 500));

      // 模拟数据
      messages.value = [
        NotificationMessage(
          id: '1',
          title: '系统更新通知',
          description: '系统将于今晚22:00进行维护更新，预计持续30分钟，请提前做好准备。',
          time: DateTime.now().subtract(const Duration(minutes: 10)),
          icon: Icons.system_update,
          isRead: false,
        ),
        NotificationMessage(
          id: '2',
          title: '新促销活动',
          description: '春季大促活动已开启，全场商品8折优惠，活动时间：3月1日-3月31日。',
          time: DateTime.now().subtract(const Duration(hours: 2)),
          icon: Icons.local_offer,
          isRead: false,
        ),
        NotificationMessage(
          id: '3',
          title: '库存预警',
          description: '商品"可口可乐500ml"库存不足，当前库存：15件，请及时补货。',
          time: DateTime.now().subtract(const Duration(hours: 5)),
          icon: Icons.warning_amber,
          isRead: true,
        ),
        NotificationMessage(
          id: '4',
          title: '收银提醒',
          description: '今日营业额已达目标的80%，继续加油！',
          time: DateTime.now().subtract(const Duration(days: 1)),
          icon: Icons.monetization_on,
          isRead: true,
        ),
        NotificationMessage(
          id: '5',
          title: '员工考勤',
          description: '员工张三今日迟到15分钟，请注意考勤管理。',
          time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          icon: Icons.access_time,
          isRead: true,
        ),
        NotificationMessage(
          id: '6',
          title: '订单通知',
          description: '您有3个新订单待处理，请及时查看。',
          time: DateTime.now().subtract(const Duration(days: 2)),
          icon: Icons.shopping_cart,
          isRead: true,
        ),
        NotificationMessage(
          id: '7',
          title: '会员提醒',
          description: '会员"李四"的会员卡即将到期，到期时间：2025-11-05。',
          time: DateTime.now().subtract(const Duration(days: 3)),
          icon: Icons.card_membership,
          isRead: true,
        ),
        NotificationMessage(
          id: '8',
          title: '设备维护',
          description: '收银设备定期维护将于本周五进行，请做好准备。',
          time: DateTime.now().subtract(const Duration(days: 4)),
          icon: Icons.build,
          isRead: true,
        ),
      ];
    } catch (e) {
      print('加载消息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 标记消息为已读
  void markAsRead(String messageId) {
    final index = messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      messages[index] = messages[index].copyWith(isRead: true);
    }
  }

  /// 标记所有消息为已读
  void markAllAsRead() {
    messages.value = messages.map((msg) => msg.copyWith(isRead: true)).toList();
  }

  /// 删除消息
  void deleteMessage(String messageId) {
    messages.removeWhere((msg) => msg.id == messageId);
  }

  /// 刷新消息列表
  Future<void> refreshMessages() async {
    await loadMessages();
  }

  /// 获取未读消息数量
  int get unreadCount => messages.where((msg) => !msg.isRead).length;
}
