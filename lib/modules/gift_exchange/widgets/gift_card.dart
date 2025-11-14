/// GiftCard
/// 礼品卡片 - 横向布局

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/app_theme.dart';
import '../../../shared/widgets/cart/product_card_wrapper.dart';
import '../models/gift_item.dart';

class GiftCard extends StatelessWidget {
  final GiftItem gift;
  final VoidCallback onTap;

  const GiftCard({super.key, required this.gift, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = gift.isSoldOut || (gift.stock ?? 0) == 0;

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
                  child: gift.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                          child: Image.network(
                            gift.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.card_giftcard,
                                size: 40.w,
                                color: Colors.grey.shade400,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.card_giftcard,
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
                              gift.name,
                              style: AppTheme.textSubtitle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isOutOfStock
                                    ? Colors.grey.shade500
                                    : AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (gift.specification != null)
                            Padding(
                              padding: EdgeInsets.only(left: AppTheme.spacingS),
                              child: Text(
                                '规格: ${gift.specification}',
                                style: AppTheme.textCaption.copyWith(
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
                            '库存: ${gift.stock ?? 0}',
                            style: AppTheme.textCaption.copyWith(
                              color: isOutOfStock
                                  ? Colors.grey.shade400
                                  : (gift.stock ?? 0) < 10
                                  ? AppTheme.warningColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${gift.price.toStringAsFixed(0)}票',
                            style: AppTheme.textSubtitle.copyWith(
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
