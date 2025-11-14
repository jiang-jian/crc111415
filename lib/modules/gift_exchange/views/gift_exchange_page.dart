/// GiftExchangePage
/// 礼品兑换主页面

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/layouts/menu_layout_page.dart';
import '../../../shared/widgets/cart/cart_section_container.dart';
import '../../../shared/widgets/cart/unified_checkout_button.dart';
import '../../../shared/widgets/member_login/member_login_dialog.dart';
import '../controllers/gift_exchange_controller.dart';
import '../widgets/gift_cart_list_view.dart';
import '../widgets/gift_total_amount_bar.dart';
import '../widgets/lottery_payment_dialog.dart';
import '../widgets/gift_grid_view.dart';
import '../widgets/gift_category_menu.dart';
import '../widgets/exchange_history_view.dart';

class GiftExchangePage extends StatelessWidget {
  const GiftExchangePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GiftExchangeController(), permanent: false);

    return Obx(() {
      final controller = Get.find<GiftExchangeController>();
      final isExchangeHistory =
          controller.categoryController.selectedCategory.value ==
          'exchange_history';

      return MenuLayoutPage(
        selectedKey: controller.categoryController.selectedCategory.value,
        contentBuilder: (_) => isExchangeHistory
            ? const ExchangeHistoryView()
            : Row(
                children: [
                  Expanded(child: _buildCartSection(context)),
                  Expanded(child: _buildContentSection()),
                ],
              ),
        menuWidget: const GiftCategoryMenu(),
        centerContent: false,
      );
    });
  }

  Widget _buildCartSection(BuildContext context) {
    final controller = Get.find<GiftExchangeController>();

    return CartSectionContainer(
      title: '购物车',
      cartItems: controller.cartController.cartItems,
      onClearCart: controller.cartController.clearCart,
      cartListView: const GiftCartListView(),
      totalAmountBar: const GiftTotalAmountBar(),
      paymentSelector: _buildLotteryPaymentSelector(),
      checkoutButton: UnifiedCheckoutButton(
        isCheckingOut: controller.paymentController.isCheckingOut,
        hasPaymentMethod: null,
        cartItems: controller.cartController.cartItems,
        buttonText: '去划扣',
        onCheckout: _handleCheckout,
      ),
    );
  }

  Widget _buildLotteryPaymentSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.confirmation_number,
                size: 28.w,
                color: AppTheme.primaryColor,
              ),
              SizedBox(height: 8.h),
              Text(
                '彩票支付',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    // 检查会员登录状态
    final isLoggedIn = await MemberLoginDialog.showQuick(context);
    if (!isLoggedIn) return;

    if (!context.mounted) return;

    // 显示支付对话框
    await LotteryPaymentDialog.show(context);
  }

  Widget _buildContentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.r),
          bottomLeft: Radius.circular(6.r),
        ),
      ),
      child: const GiftGridView(),
    );
  }
}
