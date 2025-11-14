/// CustomerMenuController
/// 顾客中心菜单管理

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/common_menu.dart';

class CustomerMenuController extends GetxController {
  final selectedMenu = 'member_query'.obs;

  static const List<MenuItem> menuItems = [
    MenuItem(key: 'member_query', label: '会员查询', icon: Icons.search),
    MenuItem(
      key: 'loss_report',
      label: '挂失',
      icon: Icons.report_problem_outlined,
      children: [
        MenuItem(key: 'quick_loss_report', label: '快速挂失', icon: Icons.circle),
        MenuItem(key: 'loss_report_list', label: '挂失列表', icon: Icons.circle),
      ],
    ),
    MenuItem(
      key: 'deposit',
      label: '存币/存票',
      icon: Icons.save_alt_outlined,
      children: [
        MenuItem(key: 'deposit_coin', label: '存币', icon: Icons.circle),
        MenuItem(key: 'deposit_ticket', label: '存票', icon: Icons.circle),
      ],
    ),
    MenuItem(
      key: 'withdraw',
      label: '取币/取票',
      icon: Icons.output_outlined,
      children: [
        MenuItem(key: 'withdraw_coin', label: '取币', icon: Icons.circle),
        MenuItem(key: 'withdraw_ticket', label: '取票', icon: Icons.circle),
      ],
    ),
    MenuItem(
      key: 'quick_refund',
      label: '快速退卡',
      icon: Icons.credit_card_off_outlined,
    ),
  ];

  void selectMenu(String menuKey) {
    selectedMenu.value = menuKey;
  }
}
