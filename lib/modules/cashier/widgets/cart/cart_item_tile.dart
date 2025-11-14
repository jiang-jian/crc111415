/// CartItemTile
/// 购物车商品条目

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_theme.dart';
import '../../models/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final int index;
  final CartItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(int) onQuantityChange;

  const CartItemTile({
    super.key,
    required this.index,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 24.w),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: .1)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
              width: isSelected ? 2.w : 1.w,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 30.w,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppTheme.spacingS),
              _buildQuantityControl(),
              SizedBox(width: AppTheme.spacingL),
              SizedBox(
                width: 80.w,
                child: Text(
                  item.subtotal.toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.priceColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.remove,
            onPressed: () => onQuantityChange(-1),
          ),
          Container(
            width: 40.w,
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ),
          _buildControlButton(
            icon: Icons.add,
            onPressed: () => onQuantityChange(1),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        width: 32.w,
        height: 36.h,
        alignment: Alignment.center,
        child: Icon(icon, size: 20.w, color: AppTheme.textPrimary),
      ),
    );
  }
}
