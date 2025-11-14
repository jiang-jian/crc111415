import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // ==================== 主题色定义 ====================
  /// 主色调 - 紫色
  static const Color primaryColor = Color(0xFF6400ff);

  /// 背景色 - 白色
  static const Color backgroundColor = Color(0xFFFFFFFF);

  /// 卡片背景色
  static const Color cardColor = Color(0xFFFFFFFF);

  // ==================== 文本颜色系统 ====================
  /// 主要文本颜色 - 深灰
  static const Color textPrimary = Color(0xFF333333);

  /// 次要文本颜色 - 中灰
  static const Color textSecondary = Color(0xFF666666);

  /// 辅助文本颜色 - 浅灰
  static const Color textTertiary = Color(0xFF999999);

  /// 禁用文本颜色 - 更浅灰
  static const Color textDisabled = Color(0xFFBBBBBB);

  // ==================== 状态颜色系统 ====================
  /// 成功状态 - 绿色
  static const Color successColor = Color(0xFF52C41A);

  /// 错误状态 - 红色
  static const Color errorColor = Color(0xFFFF4D4F);

  /// 警告状态 - 橙色
  static const Color warningColor = Color(0xFFF39C12);

  /// 信息状态 - 蓝色
  static const Color infoColor = Color(0xFF1890FF);

  /// 危险操作 - 品红色
  static const Color dangerColor = Color(0xFFFF00BD);

  // ==================== 边框与分割线 ====================
  /// 边框颜色
  static const Color borderColor = Color(0xFFE0E0E0);

  /// 浅边框颜色
  static const Color borderColorLight = Color(0xFFE8E8E8);

  /// 分割线颜色
  static const Color dividerColor = Color(0xFFEEEEEE);

  // ==================== 背景色系统 ====================
  /// 浅灰背景
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  /// 浅卡片背景
  static const Color backgroundCard = Color(0xFFFBFBFB);

  /// 禁用背景
  static const Color backgroundDisabled = Color(0xFFD9D9D9);

  // ==================== 业务颜色 ====================
  /// 金额红色
  static const Color priceColor = Color(0xFFE53935);

  /// 套餐卡片黄色边框
  static const Color packageBorderColor = Color(0xFFFFB74D);

  /// 套餐卡片黄色背景
  static const Color packageBgColor = Color(0xFFFFF3E0);

  // ==================== 状态背景色(浅色版) ====================
  /// 信息状态背景
  static const Color infoBgColor = Color(0xFFF0F7FF);

  /// 成功状态背景
  static const Color successBgColor = Color(0xFFF0F9FF);

  /// 错误状态背景
  static const Color errorBgColor = Color(0xFFFFF1F0);

  /// 警告状态背景
  static const Color warningBgColor = Color(0xFFFFFBE6);

  // ==================== 圆角规范 ====================
  /// 小圆角 - 用于按钮/输入框等小组件
  static double get borderRadiusSmall => 4.r;

  /// 中等圆角 - 用于次级卡片
  static double get borderRadiusMedium => 6.r;

  /// 默认圆角 - 最常用，卡片/容器默认值
  static double get borderRadiusDefault => 8.r;

  /// 大圆角 - 用于主要卡片
  static double get borderRadiusLarge => 12.r;

  /// 超大圆角 - 用于对话框/抽屉
  static double get borderRadiusXLarge => 16.r;

  /// 圆形圆角 - 用于头像/图标按钮
  static double get borderRadiusRound => 20.r;

  // ==================== 间距规范 ====================
  /// 超小间距 - 4
  static double get spacingXS => 4.w;

  /// 小间距 - 8
  static double get spacingS => 8.w;

  /// 中等间距 - 12
  static double get spacingM => 12.w;

  /// 默认间距 - 16
  static double get spacingDefault => 16.w;

  /// 大间距 - 24
  static double get spacingL => 24.w;

  /// 超大间距 - 32
  static double get spacingXL => 32.w;

  // ==================== 文本样式系统 ====================
  /// 超小文字 - 11sp (终端日志/代码)
  static TextStyle get textMini =>
      TextStyle(fontSize: 11.sp, color: textSecondary, fontFamily: 'monospace');

  /// 辅助文字 - 12sp
  static TextStyle get textCaption =>
      TextStyle(fontSize: 12.sp, color: textSecondary);

  /// 正文/标签 - 14sp
  static TextStyle get textBody =>
      TextStyle(fontSize: 14.sp, color: textPrimary);

  /// 标题/重要文本 - 16sp
  static TextStyle get textSubtitle =>
      TextStyle(fontSize: 16.sp, color: textPrimary);

  /// 小标题 - 18sp
  static TextStyle get textTitle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  /// 大标题 - 20sp
  static TextStyle get textHeading => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  /// 超大标题 - 24sp
  static TextStyle get textLarge => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  /// 展示标题 - 32sp
  static TextStyle get textDisplay => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // ==================== 常用装饰方法 ====================
  /// 标准卡片装饰
  ///
  /// [color] 背景色，默认白色
  /// [borderRadius] 圆角，默认 12.r
  /// [withShadow] 是否带阴影，默认 true
  /// [borderColor] 边框颜色，默认无边框
  static BoxDecoration cardDecoration({
    Color? color,
    double? borderRadius,
    bool withShadow = true,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? cardColor,
      borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusLarge),
      border: borderColor != null
          ? Border.all(color: borderColor, width: 1.w)
          : null,
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ]
          : null,
    );
  }

  /// 灰色容器装饰
  ///
  /// [borderRadius] 圆角，默认 8.r
  static BoxDecoration greyContainerDecoration({double? borderRadius}) {
    return BoxDecoration(
      color: backgroundGrey,
      borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusDefault),
    );
  }

  /// 状态容器装饰
  ///
  /// [type] 状态类型: 'info', 'success', 'error', 'warning'
  /// [borderRadius] 圆角，默认 8.r
  static BoxDecoration statusContainerDecoration({
    required String type,
    double? borderRadius,
  }) {
    Color bgColor;
    Color bColor;

    switch (type) {
      case 'info':
        bgColor = infoBgColor;
        bColor = infoColor;
        break;
      case 'success':
        bgColor = successBgColor;
        bColor = successColor;
        break;
      case 'error':
        bgColor = errorBgColor;
        bColor = errorColor;
        break;
      case 'warning':
        bgColor = warningBgColor;
        bColor = warningColor;
        break;
      default:
        bgColor = backgroundGrey;
        bColor = borderColor;
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusDefault),
      border: Border.all(color: bColor.withValues(alpha: 0.3), width: 1.w),
    );
  }

  /// 渐变背景装饰
  ///
  /// [colors] 渐变颜色列表，默认主色渐变
  /// [borderRadius] 圆角，默认 12.r
  static BoxDecoration gradientDecoration({
    List<Color>? colors,
    double? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors ?? [primaryColor, primaryColor.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusLarge),
    );
  }

  // ==================== 涟漪按钮样式 ====================
  /// 透明涟漪图标按钮
  ///
  /// [icon] 图标
  /// [onTap] 点击回调
  /// [size] 按钮尺寸，默认 40
  /// [iconSize] 图标尺寸，默认 20
  /// [disabled] 是否禁用，默认 false
  /// [showBadge] 是否显示角标，默认 false
  static Widget rippleIconButton({
    required IconData icon,
    VoidCallback? onTap,
    double? size,
    double? iconSize,
    bool disabled = false,
    bool showBadge = false,
  }) {
    final buttonSize = size ?? 40.w;
    final iconSizeValue = iconSize ?? 20.sp;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(borderRadiusRound),
        splashColor: disabled
            ? Colors.transparent
            : primaryColor.withValues(alpha: .1),
        highlightColor: disabled
            ? Colors.transparent
            : primaryColor.withValues(alpha: .05),
        child: Ink(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: disabled
                ? borderColor.withValues(alpha: .3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadiusRound),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: iconSizeValue,
                color: disabled ? textTertiary : textSecondary,
              ),
              if (showBadge && !disabled)
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(
                      color: errorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 透明涟漪文字按钮
  ///
  /// [child] 子组件（通常是 Row）
  /// [onTap] 点击回调
  /// [height] 按钮高度，默认 40
  /// [padding] 内边距，默认水平 16
  static Widget rippleTextButton({
    required Widget child,
    required VoidCallback onTap,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadiusRound),
        splashColor: primaryColor.withValues(alpha: .1),
        highlightColor: primaryColor.withValues(alpha: .05),
        child: Ink(
          height: height ?? 40.h,
          padding: padding ?? EdgeInsets.symmetric(horizontal: spacingDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadiusRound),
          ),
          child: child,
        ),
      ),
    );
  }

  // ==================== Material 主题配置 ====================
  static ThemeData get materialTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      // 设置默认水波纹工厂
      splashFactory: InkRipple.splashFactory,
      splashColor: Colors.white.withValues(alpha: 0.2),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      // Card 主题
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(8.w),
      ),
      // InputDecoration 主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: borderColor, width: 1.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: borderColor, width: 1.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: primaryColor, width: 2.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: errorColor, width: 1.w),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: errorColor, width: 2.w),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        // Label 样式
        labelStyle: TextStyle(fontSize: 16.sp, color: Colors.black54),
        // 浮动 Label 样式
        floatingLabelStyle: TextStyle(fontSize: 16.sp, color: primaryColor),
        // Hint 样式
        hintStyle: TextStyle(fontSize: 16.sp, color: Colors.black38),
      ),
      // ElevatedButton 主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFD9D9D9),
          disabledForegroundColor: const Color(0xFFBBBBBB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal),
        ),
      ),
      // OutlinedButton 主题
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal),
        ),
      ),
      // TextButton 主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      // IconButton 主题
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textSecondary,
          hoverColor: primaryColor.withValues(alpha: 0.1),
        ),
      ),
      // Divider 主题
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1.h,
        space: 1.h,
      ),
      // Dialog 主题
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        contentTextStyle: TextStyle(fontSize: 14.sp, color: textSecondary),
      ),
      // SnackBar 主题
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        behavior: SnackBarBehavior.floating,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      // TabBar 主题
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryColor,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }
}
