/// CashierPage
/// 收银台主页面 - 充值套餐选择与结账

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/widgets/layouts/menu_layout_page.dart';
import '../controllers/cashier_controller.dart';
import '../widgets/cart/cart_list_view.dart';
import '../widgets/cart/discount_info_section.dart';
import '../widgets/cart/total_amount_bar.dart';
import '../widgets/payment/payment_method_selector.dart';
import '../widgets/payment/cash_payment_dialog.dart';
import '../widgets/payment/card_payment_dialog.dart';
import '../widgets/package/package_list_view.dart';
import '../widgets/package/voucher_grid_view.dart';
import '../widgets/package/retail_grid_view.dart';
import '../../../shared/widgets/cart/cart_section_container.dart';
import '../../../shared/widgets/cart/unified_checkout_button.dart';
import '../../../shared/widgets/member_login/member_login_dialog.dart';
import '../widgets/package/category_accordion.dart';
import '../widgets/sign_coin/sign_coin_view.dart';

class CashierPage extends StatelessWidget {
  const CashierPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CashierController(), permanent: false);

    return Obx(() {
      final categoryController = Get.find<CategoryController>();
      final isSignCoin =
          categoryController.selectedCategory.value == 'sign_coin';

      return MenuLayoutPage(
        selectedKey: categoryController.selectedCategory.value,
        contentBuilder: (_) => isSignCoin
            ? const SignCoinView()
            : Row(children: [_buildLeftSection(), _buildPackageSection()]),
        menuWidget: const CategoryAccordion(),
        contentPadding: EdgeInsets.zero,
        centerContent: false,
      );
    });
  }

  Widget _buildLeftSection() {
    return Expanded(flex: 3, child: _buildCartSection());
  }

  Widget _buildCartSection() {
    final controller = Get.find<CashierController>();

    return CartSectionContainer(
      title: '购物车',
      cartItems: controller.cartController.cartItems,
      onClearCart: controller.cartController.clearCart,
      cartListView: const CartListView(),
      extraInfoSection: const DiscountInfoSection(),
      totalAmountBar: const TotalAmountBar(),
      paymentSelector: const PaymentMethodSelector(),
      checkoutButton: Obx(() {
        final hasMethod =
            controller.paymentController.selectedPaymentMethod.value != null;
        return UnifiedCheckoutButton(
          isCheckingOut: controller.paymentController.isCheckingOut,
          hasPaymentMethod: hasMethod.obs,
          cartItems: controller.cartController.cartItems,
          buttonText: '收银',
          onCheckout: _handleCheckout,
        );
      }),
    );
  }

  Widget _buildPackageSection() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.r),
            bottomLeft: Radius.circular(6.r),
          ),
        ),
        child: Obx(() {
          final categoryController = Get.find<CategoryController>();
          final selectedCategory = categoryController.selectedCategory.value;

          if (selectedCategory == 'sign_coin') {
            return const SizedBox.shrink();
          }

          final categoryParent = categoryController.getCategoryParent(
            selectedCategory,
          );

          if (categoryParent == 'vouchers') {
            return const VoucherGridView();
          } else if (categoryParent == 'retail') {
            return const RetailGridView();
          } else {
            return const PackageListView();
          }
        }),
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    // 检查会员登录状态
    final isLoggedIn = await MemberLoginDialog.showQuick(context);
    if (!isLoggedIn) return;

    if (!context.mounted) return;

    // 根据选择的支付方式显示对应的对话框
    final controller = Get.find<CashierController>();
    final paymentMethod =
        controller.paymentController.selectedPaymentMethod.value;

    if (paymentMethod?.name == 'card') {
      await CardPaymentDialog.show(context);
    } else {
      await CashPaymentDialog.show(context);
    }
  }
}
