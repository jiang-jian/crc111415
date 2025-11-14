/// ProductCardWrapper
/// 商品卡片通用包装器 - 提供统一的涟漪效果和背景色

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// 商品卡片通用样式配置
class ProductCardStyle {
  // 背景色 - 使用 AppTheme 定义
  static const Color bgColor = AppTheme.backgroundCard;
  static const Color borderColor = AppTheme.borderColorLight;
  static const Color outOfStockBgColor = AppTheme.backgroundGrey;
  static const Color outOfStockBorderColor = AppTheme.borderColor;

  // 涟漪颜色
  static const Color splashColor = Color(0xFFFF6B35);
  static const double splashOpacity = 0.15;
  static const double highlightOpacity = 0.06;

  // 圆角 - 使用 AppTheme 定义
  static double get borderRadius => AppTheme.borderRadiusDefault;

  // 阴影
  static const int elevation = 1;
}

/// 商品卡片包装器 - 提供涟漪效果和背景色
class ProductCardWrapper extends StatelessWidget {
  /// 卡片内容
  final Widget child;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否缺货
  final bool isOutOfStock;

  /// 圆角（可选，默认为8）
  final double? borderRadius;

  /// 自定义圆角数值
  final BorderRadiusGeometry? customBorderRadius;

  const ProductCardWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.isOutOfStock = false,
    this.borderRadius,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius =
        customBorderRadius ??
        BorderRadius.circular(borderRadius ?? ProductCardStyle.borderRadius);

    return Material(
      color: isOutOfStock
          ? ProductCardStyle.outOfStockBgColor
          : ProductCardStyle.bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: isOutOfStock
              ? ProductCardStyle.outOfStockBorderColor
              : ProductCardStyle.borderColor,
          width: 1.w,
        ),
      ),
      elevation: isOutOfStock ? 0 : ProductCardStyle.elevation.toDouble(),
      child: InkWell(
        onTap: isOutOfStock ? null : onTap,
        borderRadius: radius is BorderRadius ? radius : null,
        splashColor: ProductCardStyle.splashColor.withValues(
          alpha: ProductCardStyle.splashOpacity,
        ),
        highlightColor: ProductCardStyle.splashColor.withValues(
          alpha: ProductCardStyle.highlightOpacity,
        ),
        child: Stack(
          children: [
            child,
            if (isOutOfStock)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: radius is BorderRadius ? radius : null,
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
