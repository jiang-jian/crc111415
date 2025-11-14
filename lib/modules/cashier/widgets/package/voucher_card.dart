/// VoucherCard
/// 兑换券卡片 - 矩形网格布局

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/cart/product_card_wrapper.dart';
import '../../models/package_item.dart';

class VoucherCard extends StatelessWidget {
  final PackageItem package;
  final VoidCallback onTap;

  const VoucherCard({super.key, required this.package, required this.onTap});

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = (package.stock ?? 1) == 0;

    return ProductCardWrapper(
      onTap: onTap,
      isOutOfStock: isOutOfStock,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(AppTheme.spacingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  package.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isOutOfStock
                        ? Colors.grey.shade500
                        : AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (package.validFrom != null && package.validTo != null)
                  Text(
                    '有效期起止:${_formatDate(package.validFrom!)} - ${_formatDate(package.validTo!)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isOutOfStock
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isOutOfStock)
            Positioned(
              right: 16.w,
              top: 8.w,
              child: SizedBox(
                width: 68.w,
                height: 68.w,
                child: SvgPicture.asset(
                  'assets/images/soldOut.svg',
                  width: 68.w,
                  height: 68.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
