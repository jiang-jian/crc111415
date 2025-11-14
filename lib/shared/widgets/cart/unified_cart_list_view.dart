/// UnifiedCartListView
/// 统一购物车列表视图

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../modules/cashier/models/cart_item.dart';
import '../../../modules/cashier/widgets/cart/cart_empty_view.dart';
import '../../../modules/cashier/widgets/cart/cart_item_tile.dart';

class UnifiedCartListView extends StatelessWidget {
  final RxList<CartItem> cartItems;
  final String priceHeaderLabel;
  final Function(String) onRemove;
  final Function(String, int) onUpdateQuantity;

  const UnifiedCartListView({
    super.key,
    required this.cartItems,
    required this.priceHeaderLabel,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cartItems.isEmpty) {
        return const CartEmptyView();
      }

      return Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return CartItemTile(
                  index: index + 1,
                  item: item,
                  isSelected: false,
                  onTap: () {},
                  onDelete: () => onRemove(item.id),
                  onQuantityChange: (delta) => onUpdateQuantity(item.id, delta),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFEEEEEE), width: 1.h),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '商品名称',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacingS),
          SizedBox(
            width: 104.w,
            child: Text(
              '数量',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacingL),
          SizedBox(
            width: 80.w,
            child: Text(
              priceHeaderLabel,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
