/// RetailCard
/// 零售商品卡片 - 横向布局

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/cart/product_card_wrapper.dart';
import '../../models/package_item.dart';

class RetailCard extends StatelessWidget {
  final PackageItem package;
  final VoidCallback onTap;

  const RetailCard({super.key, required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = package.isSoldOut || (package.stock ?? 0) == 0;

    return ProductCardWrapper(
      onTap: onTap,
      isOutOfStock: isOutOfStock,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                  ),
                  child: package.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                          child: Image.network(
                            package.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.fastfood,
                                size: 40.w,
                                color: Colors.grey.shade400,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.fastfood,
                          size: 40.w,
                          color: Colors.grey.shade400,
                        ),
                ),
                SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              package.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: isOutOfStock
                                    ? Colors.grey.shade500
                                    : AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (package.specification != null)
                            Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Text(
                                '规格: ${package.specification}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isOutOfStock
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '库存: ${package.stock ?? 0}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isOutOfStock
                                  ? Colors.grey.shade400
                                  : (package.stock ?? 0) < 10
                                  ? Colors.orange
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'AED ${package.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isOutOfStock
                                  ? Colors.grey.shade400
                                  : AppTheme.priceColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isOutOfStock)
            Positioned(
              left: 240.w,
              top: 16.w,
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
