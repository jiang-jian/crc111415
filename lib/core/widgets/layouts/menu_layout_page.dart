/// MenuLayoutPage
/// 通用的左右布局页面，右侧为菜单，左侧为内容区

import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuLayoutPage extends StatelessWidget {
  /// 内容构建器，根据选中的菜单 key 构建对应内容
  final Widget Function(String selectedKey) contentBuilder;

  /// 右侧菜单组件
  final Widget menuWidget;

  /// 当前选中的菜单 key
  final String selectedKey;

  /// 左侧内容区背景色
  final Color? contentBackgroundColor;

  /// 左侧内容区圆角（默认右上右下圆角）
  final BorderRadius? contentBorderRadius;

  /// 左侧内容区内边距
  final EdgeInsets? contentPadding;

  /// 页面背景色
  final Color? backgroundColor;

  /// 是否居中显示内容（默认 true）
  final bool centerContent;

  /// 左侧内容区 flex 值（默认 1）
  final int contentFlex;

  const MenuLayoutPage({
    super.key,
    required this.contentBuilder,
    required this.menuWidget,
    required this.selectedKey,
    this.contentBackgroundColor,
    this.contentBorderRadius,
    this.contentPadding,
    this.backgroundColor,
    this.centerContent = true,
    this.contentFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF6F6F6),
      body: Row(
        children: [
          Expanded(
            flex: contentFlex,
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: contentBackgroundColor ?? Colors.white,
                  borderRadius:
                      contentBorderRadius ??
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: _buildContentWithAlignment(),
              ),
            ),
          ),
          menuWidget,
        ],
      ),
    );
  }

  Widget _buildContentWithAlignment() {
    return centerContent ? Center(child: _buildContent()) : _buildContent();
  }

  Widget _buildContent() {
    final content = contentBuilder(selectedKey);
    return contentPadding != null
        ? Container(padding: contentPadding, child: content)
        : content;
  }
}
