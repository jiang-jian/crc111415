/// PackageCard
/// 充值套餐卡片

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/cart/product_card_wrapper.dart';
import '../../models/package_item.dart';

class PackageCard extends StatelessWidget {
  final PackageItem package;
  final VoidCallback onTap;

  const PackageCard({super.key, required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = (package.stock ?? 1) == 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: ProductCardWrapper(
        onTap: onTap,
        isOutOfStock: isOutOfStock,
        borderRadius: 12,
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingDefault),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      package.description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isOutOfStock
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Text(
                    'AED ${package.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock
                          ? Colors.grey.shade400
                          : AppTheme.priceColor,
                    ),
                  ),
                  if (isOutOfStock)
                    Positioned(
                      left: -40.w,
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
            ],
          ),
        ),
      ),
    );
  }
}
