/// Drawer
/// 全局抽屉组件 - 参考 Toast/Loading 实现

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 抽屉位置
enum DrawerPosition { left, right }

/// 全局抽屉管理器
class CustomDrawer {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// 显示抽屉
  static void show({
    required BuildContext context,
    required Widget child,
    DrawerPosition position = DrawerPosition.right,
    double? width,
    double? topOffset,
  }) {
    if (_isShowing) return;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => _DrawerWidget(
        width: width,
        position: position,
        topOffset: topOffset,
        onClose: () => hide(),
        child: child,
      ),
    );

    overlay.insert(_overlayEntry!);
    _isShowing = true;
  }

  /// 隐藏抽屉
  static void hide() {
    if (!_isShowing || _overlayEntry == null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }

  /// 判断是否正在显示
  static bool get isShowing => _isShowing;
}

class _DrawerWidget extends StatefulWidget {
  final double? width;
  final DrawerPosition position;
  final double? topOffset;
  final VoidCallback onClose;
  final Widget child;

  const _DrawerWidget({
    required this.position,
    required this.onClose,
    required this.child,
    this.width,
    this.topOffset,
  });

  @override
  State<_DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<_DrawerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 根据位置设置滑动方向
    final begin = widget.position == DrawerPosition.right
        ? const Offset(1, 0) // 从右侧滑入
        : const Offset(-1, 0); // 从左侧滑入

    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final topOffset = widget.topOffset ?? 0;

    return Stack(
      children: [
        // 遮罩层
        Positioned.fill(
          top: topOffset,
          child: GestureDetector(
            onTap: _close,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black.withValues(alpha: .5)),
            ),
          ),
        ),
        // 抽屉
        Positioned(
          left: widget.position == DrawerPosition.left ? 0 : null,
          right: widget.position == DrawerPosition.right ? 0 : null,
          top: topOffset,
          bottom: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              elevation: 16,
              child: SizedBox(
                width: widget.width ?? 320.w,
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
