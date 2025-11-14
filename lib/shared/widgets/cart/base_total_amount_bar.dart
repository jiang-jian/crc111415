/// BaseTotalAmountBar
/// 通用总计金额栏

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

class BaseTotalAmountBar extends StatelessWidget {
  final double subtotal;
  final double totalAmount;
  final bool hasItems;
  final String currency;

  const BaseTotalAmountBar({
    super.key,
    required this.subtotal,
    required this.totalAmount,
    required this.hasItems,
    this.currency = 'AED',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Column(
        children: [
          if (hasItems) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '小计：',
                  style: AppTheme.textBody.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  currency == '票'
                      ? '${subtotal.toStringAsFixed(0)}$currency'
                      : '$currency ${subtotal.toStringAsFixed(2)}',
                  style: AppTheme.textBody.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingS),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '总计：',
                style: AppTheme.textSubtitle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0, end: totalAmount),
                builder: (context, value, child) {
                  return Text(
                    currency == '票'
                        ? '${value.toStringAsFixed(0)}$currency'
                        : '$currency ${value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.priceColor,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
