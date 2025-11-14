import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/theme/app_theme.dart';
import 'app_overlay.dart';

/// AppDialog
/// 全局统一对话框组件
/// 作者:AI 自动生成
/// 更新时间:2025-11-10

/// 对话框配置类
class DialogConfig {
  final String? title;
  final Widget? content;
  final String? contentText;
  final String confirmText;
  final String cancelText;
  final bool showConfirm;
  final bool showCancel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final double width;
  final bool barrierDismissible;
  final Widget? icon;
  final Color? confirmColor;
  final Color? cancelColor;
  final bool isDanger;
  final ValueListenable<bool>? isLoadingNotifier;
  final ValueListenable<bool>? canConfirmNotifier;
  final double? maxHeight;
  final bool autoCloseOnConfirm; // 新增:点击确认后是否自动关闭

  const DialogConfig({
    this.title,
    this.content,
    this.contentText,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.showConfirm = true,
    this.showCancel = true,
    this.onConfirm,
    this.onCancel,
    this.width = 400,
    this.barrierDismissible = true,
    this.icon,
    this.confirmColor,
    this.cancelColor,
    this.isDanger = false,
    this.isLoadingNotifier,
    this.canConfirmNotifier,
    this.maxHeight,
    this.autoCloseOnConfirm = true, // 默认自动关闭
  }) : assert(
         content != null || contentText != null,
         'content or contentText must be provided',
       );
}

/// 全局 Dialog 管理器
class AppDialog {
  static OverlayEntry? _currentOverlayEntry;

  /// 显示对话框
  static Future<bool?> show({
    String? title,
    Widget? content,
    String? contentText,
    String confirmText = '确定',
    String cancelText = '取消',
    bool showConfirm = true,
    bool showCancel = true,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    double width = 400,
    bool barrierDismissible = true,
    Widget? icon,
    Color? confirmColor,
    Color? cancelColor,
    bool isDanger = false,
    ValueListenable<bool>? isLoadingNotifier,
    ValueListenable<bool>? canConfirmNotifier,
    double? maxHeight,
    bool autoCloseOnConfirm = true,
  }) {
    final config = DialogConfig(
      title: title,
      content: content,
      contentText: contentText,
      confirmText: confirmText,
      cancelText: cancelText,
      showConfirm: showConfirm,
      showCancel: showCancel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      width: width,
      barrierDismissible: barrierDismissible,
      icon: icon,
      confirmColor: confirmColor,
      cancelColor: cancelColor,
      isDanger: isDanger,
      isLoadingNotifier: isLoadingNotifier,
      canConfirmNotifier: canConfirmNotifier,
      maxHeight: maxHeight,
      autoCloseOnConfirm: autoCloseOnConfirm,
    );

    return _showDialog(config);
  }

  /// 显示确认对话框
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmText = '确定',
    String cancelText = '取消',
    double width = 400,
    bool barrierDismissible = true,
    bool isDanger = false,
  }) async {
    final result = await show(
      title: title,
      contentText: message,
      confirmText: confirmText,
      cancelText: cancelText,
      showConfirm: true,
      showCancel: true,
      width: width,
      barrierDismissible: barrierDismissible,
      isDanger: isDanger,
    );
    return result == true;
  }

  /// 显示警告对话框
  static Future<bool> warning({
    required String title,
    required String message,
    String confirmText = '确定',
    String cancelText = '取消',
    double width = 400,
  }) async {
    final result = await show(
      title: title,
      contentText: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48.w),
      isDanger: true,
      width: width,
    );
    return result == true;
  }

  /// 显示信息对话框(只有确定按钮)
  static Future<void> info({
    required String title,
    required String message,
    String confirmText = '确定',
    double width = 400,
  }) async {
    await show(
      title: title,
      contentText: message,
      confirmText: confirmText,
      showCancel: false,
      width: width,
      icon: Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 48.w),
    );
  }

  /// 显示错误对话框
  static Future<void> error({
    required String title,
    required String message,
    String confirmText = '确定',
    double width = 400,
  }) async {
    await show(
      title: title,
      contentText: message,
      confirmText: confirmText,
      showCancel: false,
      width: width,
      icon: Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48.w),
      isDanger: true,
    );
  }

  /// 显示成功对话框
  static Future<void> success({
    required String title,
    required String message,
    String confirmText = '确定',
    double width = 400,
  }) async {
    await show(
      title: title,
      contentText: message,
      confirmText: confirmText,
      showCancel: false,
      width: width,
      icon: Icon(Icons.check_circle_outline, color: Colors.green, size: 48.w),
    );
  }

  /// 显示自定义内容对话框
  static Future<bool?> custom({
    String? title,
    required Widget content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool showConfirm = true,
    bool showCancel = true,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    double width = 400,
    bool barrierDismissible = true,
    bool isDanger = false,
    ValueListenable<bool>? isLoadingNotifier,
    ValueListenable<bool>? canConfirmNotifier,
    double? maxHeight,
    bool autoCloseOnConfirm = true,
  }) {
    return show(
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      showConfirm: showConfirm,
      showCancel: showCancel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      width: width,
      barrierDismissible: barrierDismissible,
      isDanger: isDanger,
      isLoadingNotifier: isLoadingNotifier,
      canConfirmNotifier: canConfirmNotifier,
      maxHeight: maxHeight,
      autoCloseOnConfirm: autoCloseOnConfirm,
    );
  }

  /// 核心显示逻辑
  static Future<bool?> _showDialog(DialogConfig config) async {
    final overlay = AppOverlay.dialogOverlayKey.currentState;
    if (overlay == null) {
      debugPrint('AppDialog: Overlay 不可用，无法显示对话框');
      return null;
    }

    final completer = Completer<bool?>();

    void closeDialog([bool? result]) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      _currentOverlayEntry?.remove();
      _currentOverlayEntry = null;
    }

    _currentOverlayEntry = OverlayEntry(
      builder: (context) {
        return _DialogWidget(config: config, onClose: closeDialog);
      },
    );

    overlay.insert(_currentOverlayEntry!);

    return completer.future;
  }

  /// 关闭当前对话框
  static void hide([bool? result]) {
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }
}

/// 对话框 Widget
class _DialogWidget extends StatefulWidget {
  final DialogConfig config;
  final Function(bool?) onClose;

  const _DialogWidget({required this.config, required this.onClose});

  @override
  State<_DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<_DialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: .9, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose([bool? result]) async {
    await _animationController.reverse();
    widget.onClose(result);
  }

  void _handleConfirm() {
    widget.config.onConfirm?.call();
    // 根据配置决定是否自动关闭
    if (widget.config.autoCloseOnConfirm) {
      _handleClose(true);
    }
  }

  void _handleCancel() {
    widget.config.onCancel?.call();
    _handleClose(false);
  }

  void _handleBarrierTap() {
    if (widget.config.barrierDismissible) {
      _handleCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.black.withValues(alpha: .5 * _opacityAnimation.value),
          child: GestureDetector(
            onTap: _handleBarrierTap,
            child: Container(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {},
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: _buildDialogContent(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogContent() {
    return Container(
      width: widget.config.width,
      constraints: BoxConstraints(
        maxHeight: widget.config.maxHeight?.h ?? 600.h,
      ),
      decoration: AppTheme.cardDecoration(
        borderRadius: AppTheme.borderRadiusXLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.config.title != null) _buildTitle(),
          Flexible(child: _buildContent()),
          if (widget.config.showConfirm || widget.config.showCancel)
            _buildActions(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        AppTheme.spacingL,
        AppTheme.spacingL,
        0,
      ),
      child: Text(widget.config.title!, style: AppTheme.textHeading),
    );
  }

  Widget _buildContent() {
    Widget contentWidget;

    if (widget.config.content != null) {
      contentWidget = widget.config.content!;
    } else {
      contentWidget = Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.config.contentText!,
          style: AppTheme.textSubtitle.copyWith(
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.spacingL),
      child: widget.config.icon != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.config.icon!,
                SizedBox(height: AppTheme.spacingDefault),
                contentWidget,
              ],
            )
          : contentWidget,
    );
  }

  Widget _buildActions() {
    final List<Widget> actions = [];

    if (widget.config.showCancel) {
      actions.add(
        Expanded(
          child: OutlinedButton(
            onPressed: _handleCancel,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 30.w,
                vertical: AppTheme.spacingDefault.h,
              ),
              side: BorderSide(
                color: widget.config.cancelColor ?? AppTheme.borderColor,
                width: 1.w,
              ),
              foregroundColor:
                  widget.config.cancelColor ?? AppTheme.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusDefault,
                ),
              ),
            ),
            child: Text(widget.config.cancelText, style: AppTheme.textSubtitle),
          ),
        ),
      );
    }

    if (widget.config.showConfirm) {
      if (actions.isNotEmpty) {
        actions.add(SizedBox(width: AppTheme.spacingDefault));
      }

      actions.add(Expanded(child: _buildConfirmButton()));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        0,
        AppTheme.spacingL,
        AppTheme.spacingL,
      ),
      child: Row(children: actions),
    );
  }

  Widget _buildConfirmButton() {
    final confirmColor =
        widget.config.confirmColor ??
        (widget.config.isDanger ? AppTheme.errorColor : AppTheme.primaryColor);

    // 如果提供了 loading 或 canConfirm 监听器，使用 ValueListenableBuilder
    if (widget.config.isLoadingNotifier != null ||
        widget.config.canConfirmNotifier != null) {
      return ValueListenableBuilder<bool>(
        valueListenable:
            widget.config.isLoadingNotifier ?? ValueNotifier(false),
        builder: (context, isLoading, _) {
          return ValueListenableBuilder<bool>(
            valueListenable:
                widget.config.canConfirmNotifier ?? ValueNotifier(true),
            builder: (context, canConfirm, _) {
              return ElevatedButton(
                onPressed: !isLoading && canConfirm ? _handleConfirm : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: AppTheme.spacingDefault.h,
                  ),
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusDefault,
                    ),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.config.confirmText,
                        style: AppTheme.textSubtitle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              );
            },
          );
        },
      );
    }

    // 默认静态按钮
    return ElevatedButton(
      onPressed: _handleConfirm,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 30.w,
          vertical: AppTheme.spacingDefault.h,
        ),
        backgroundColor: confirmColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        ),
      ),
      child: Text(
        widget.config.confirmText,
        style: AppTheme.textSubtitle.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
