import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// 读卡成功弹窗
class CardReadingSuccessDialog extends StatefulWidget {
  final String? cardNumber; // 读取到的卡号
  final Duration displayDuration; // 显示时长

  const CardReadingSuccessDialog({
    super.key,
    this.cardNumber,
    this.displayDuration = const Duration(seconds: 2),
  });

  @override
  State<CardReadingSuccessDialog> createState() =>
      _CardReadingSuccessDialogState();
}

class _CardReadingSuccessDialogState extends State<CardReadingSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 创建动画控制器
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 缩放动画 - 从 0.8 到 1.0
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // 淡入动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // 启动动画
    _controller.forward();

    // 自动关闭
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 380.w,
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 24.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderColor,
                        width: 1.h,
                      ),
                    ),
                  ),
                  child: Text(
                    '读卡登记',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 40.h),

                // 成功图标 - 绿色对勾
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 48.sp,
                    color: const Color(0xFF4CAF50),
                  ),
                ),

                SizedBox(height: 24.h),

                // 成功文字
                Text(
                  '读卡成功',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),

                // 显示卡号（可选）
                if (widget.cardNumber != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    '卡号：${widget.cardNumber}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 显示读卡成功弹窗
void showCardReadingSuccessDialog(
  BuildContext context, {
  String? cardNumber,
  Duration displayDuration = const Duration(seconds: 2),
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // 不允许点击外部关闭
    barrierColor: Colors.black.withValues(alpha: 0.5), // 半透明遮罩
    builder: (context) => CardReadingSuccessDialog(
      cardNumber: cardNumber,
      displayDuration: displayDuration,
    ),
  );
}
