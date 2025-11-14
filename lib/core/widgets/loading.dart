import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/theme/app_theme.dart';
import 'app_overlay.dart';

/// 全局 Loading 管理器
class Loading {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// 显示 Loading
  static void show({String? message}) {
    if (_isShowing) return;

    final overlay = AppOverlay.loadingOverlayKey.currentState;
    if (overlay == null) {
      debugPrint('Loading: Overlay 不可用，无法显示 Loading');
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(message: message),
    );

    overlay.insert(_overlayEntry!);
    _isShowing = true;
  }

  /// 隐藏 Loading
  static void hide() {
    if (!_isShowing || _overlayEntry == null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }

  /// 判断是否正在显示
  static bool get isShowing => _isShowing;
}

class _LoadingWidget extends StatefulWidget {
  final String? message;

  const _LoadingWidget({this.message});

  @override
  State<_LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<_LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(opacity: _opacityAnimation.value, child: child);
      },
      child: Material(
        color: Colors.black.withValues(alpha: .4),
        child: Center(
          child: Container(
            constraints: BoxConstraints(minWidth: 160.w),
            padding: EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 20.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48.w,
                  height: 48.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
                if (widget.message != null) ...[
                  SizedBox(height: 20.h),
                  Text(
                    widget.message!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
