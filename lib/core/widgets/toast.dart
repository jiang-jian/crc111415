import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/theme/app_theme.dart';
import 'app_overlay.dart';

class _ToastItem {
  final ValueNotifier<double> topOffset;
  final String message;
  final Color backgroundColor;
  final GlobalKey globalKey;
  double? actualHeight;

  _ToastItem({
    required this.topOffset,
    required this.message,
    required this.backgroundColor,
    required this.globalKey,
  });
}

/// 全局 Toast 管理器
class Toast {
  static double _toastTopOffset = 20;
  static const double _toastSpacing = 12;
  static const double _initialTopOffset = 20;
  static final List<_ToastItem> _toastItems = [];

  /// 显示 Toast
  static void show({
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = AppOverlay.toastOverlayKey.currentState;
    if (overlay == null) {
      debugPrint('Toast: Overlay 不可用，无法显示 Toast');
      return;
    }

    final currentTopOffset = _toastTopOffset;
    final globalKey = GlobalKey();

    // 预估高度：基础高度 + padding + 根据文本长度估算的行数
    final estimatedHeight = _estimateToastHeight(message);
    _toastTopOffset += estimatedHeight + _toastSpacing;

    late OverlayEntry overlayEntry;
    final toastItem = _ToastItem(
      topOffset: ValueNotifier(currentTopOffset),
      message: message,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      globalKey: globalKey,
    );

    // 使用单次 Ticker Provider
    final vsync = _SingleTickerProvider();
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: vsync,
    );

    final opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    overlayEntry = OverlayEntry(
      builder: (context) => ValueListenableBuilder<double>(
        valueListenable: toastItem.topOffset,
        builder: (context, topOffset, _) {
          return Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: IgnorePointer(
                    ignoring: false,
                    child: AnimatedBuilder(
                      animation: opacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: opacityAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        key: globalKey,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        constraints: BoxConstraints(maxWidth: 0.8.sw),
                        decoration: BoxDecoration(
                          color: toastItem.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .2),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // 记录当前 Toast
    _toastItems.add(toastItem);

    overlay.insert(overlayEntry);

    // 播放淡入动画
    animationController.forward();

    // 在下一帧获取实际高度并更新（用于精确调整）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          globalKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final actualHeight = renderBox.size.height;
        toastItem.actualHeight = actualHeight;

        // 如果实际高度与预估高度有差异，调整后续 Toast 的位置
        final heightDiff = actualHeight - estimatedHeight;
        if (heightDiff.abs() > 1) {
          _toastTopOffset += heightDiff;
          _adjustSubsequentToastPositions(toastItem, heightDiff);
        }
      }
    });

    // 指定时间后播放淡出动画
    Future.delayed(duration, () {
      animationController.reverse().then((_) {
        overlayEntry.remove();
        animationController.dispose();
        vsync.dispose();

        // 移除当前 Toast
        _toastItems.remove(toastItem);

        // 重新计算所有 Toast 的位置
        _recalculateToastPositions();
      });
    });
  }

  /// 显示成功提示
  static void success({
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      message: message,
      backgroundColor: AppTheme.successColor,
      duration: duration,
    );
  }

  /// 显示错误提示
  static void error({
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      message: message,
      backgroundColor: AppTheme.warningColor,
      duration: duration,
    );
  }

  /// 显示信息提示
  static void info({
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      message: message,
      backgroundColor: AppTheme.textSecondary,
      duration: duration,
    );
  }

  /// 预估 Toast 高度
  static double _estimateToastHeight(String message) {
    // 基础高度：padding (12.h * 2) + 文本行高
    final basePadding = 24.0; // 12.h * 2
    final fontSize = 14.0;
    final lineHeight = fontSize * 1.5; // 估算行高为字体大小的1.5倍

    // 计算最大宽度（屏幕宽度的80% - 左右padding）
    final maxWidth = (ScreenUtil().screenWidth * 0.8) - 48.0; // 48.w = 24.w * 2

    // 估算字符宽度（中文字符约等于fontSize，英文约为fontSize的0.6）
    final charsPerLine = (maxWidth / fontSize).floor();

    // 计算换行符数量
    final newlineCount = '\n'.allMatches(message).length;

    // 估算总行数
    final estimatedLines =
        ((message.length / charsPerLine).ceil() + newlineCount).clamp(1, 10);

    return basePadding + (lineHeight * estimatedLines);
  }

  /// 调整后续 Toast 的位置
  static void _adjustSubsequentToastPositions(
    _ToastItem referenceItem,
    double heightDiff,
  ) {
    bool foundReference = false;
    for (var item in _toastItems) {
      if (foundReference) {
        item.topOffset.value += heightDiff;
      } else if (item == referenceItem) {
        foundReference = true;
      }
    }
  }

  /// 重新计算所有 Toast 的位置
  static void _recalculateToastPositions() {
    double newTopOffset = _initialTopOffset;
    for (var item in _toastItems) {
      item.topOffset.value = newTopOffset;
      if (item.actualHeight != null) {
        newTopOffset += item.actualHeight! + _toastSpacing;
      } else {
        // 如果高度未计算，使用估算值
        newTopOffset += 48 + _toastSpacing;
      }
    }
    _toastTopOffset = newTopOffset;
  }
}

/// 单次 Ticker Provider
class _SingleTickerProvider extends TickerProvider {
  Ticker? _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _ticker = Ticker(onTick);
    return _ticker!;
  }

  void dispose() {
    _ticker?.dispose();
  }
}
