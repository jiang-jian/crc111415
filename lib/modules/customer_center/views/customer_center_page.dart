/// CustomerCenterPage
/// 顾客中心主页面

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/layouts/menu_layout_page.dart';
import '../controllers/customer_center_controller.dart';
import '../controllers/customer_menu_controller.dart';
import '../widgets/customer_menu_accordion.dart';
import 'pages/member_query_page.dart';
import 'pages/quick_loss_report_page.dart';
import 'pages/loss_report_list_page.dart';
import 'pages/deposit_coin_page.dart';
import 'pages/deposit_ticket_page.dart';
import 'pages/withdraw_coin_page.dart';
import 'pages/withdraw_ticket_page.dart';
import 'pages/quick_refund_page.dart';

class CustomerCenterPage extends GetView<CustomerMenuController> {
  const CustomerCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CustomerCenterController(), permanent: false);
    if (!Get.isRegistered<CustomerMenuController>()) {
      Get.put(CustomerMenuController());
    }

    return Obx(
      () => MenuLayoutPage(
        selectedKey: controller.selectedMenu.value,
        contentBuilder: _buildContent,
        menuWidget: const CustomerMenuAccordion(),
        centerContent: false,
      ),
    );
  }

  Widget _buildContent(String selectedMenu) {
    switch (selectedMenu) {
      case 'member_query':
        return const MemberQueryPage();
      case 'quick_loss_report':
        return const QuickLossReportPage();
      case 'loss_report_list':
        return const LossReportListPage();
      case 'deposit_coin':
        return const DepositCoinPage();
      case 'deposit_ticket':
        return const DepositTicketPage();
      case 'withdraw_coin':
        return const WithdrawCoinPage();
      case 'withdraw_ticket':
        return const WithdrawTicketPage();
      case 'quick_refund':
        return const QuickRefundPage();
      default:
        return const MemberQueryPage();
    }
  }
}
