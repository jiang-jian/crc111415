import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/dialog.dart';
import '../../../app/theme/app_theme.dart';

/// 显示读卡中弹窗
void showCardReadingDialog(BuildContext context) {
  AppDialog.custom(
    title: '读卡登记',
    content: const _CardReadingContent(),
    showConfirm: false,
    showCancel: false,
    width: 400.w,
    barrierDismissible: false,
  );
}

/// 关闭读卡中弹窗
void hideCardReadingDialog(BuildContext context) {
  AppDialog.hide();
}

/// 读卡中内容
class _CardReadingContent extends StatefulWidget {
  const _CardReadingContent();

  @override
  State<_CardReadingContent> createState() => _CardReadingContentState();
}

class _CardReadingContentState extends State<_CardReadingContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 创建动画控制器 - 2秒循环
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true); // 往返循环

    // 创建渐变动画 - 从 0.3 到 1.0
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 读卡图标
        Icon(Icons.credit_card, size: 64.sp, color: const Color(0xFFE5B544)),

        SizedBox(height: 24.h),

        // 动态文字 - 读卡登记中...
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Color.lerp(
                      AppTheme.textSecondary,
                      const Color(0xFF2C3E50),
                      _animation.value,
                    )!,
                    Color.lerp(
                      AppTheme.textTertiary,
                      const Color(0xFF2C3E50),
                      _animation.value,
                    )!,
                  ],
                  stops: const [0.0, 1.0],
                ).createShader(bounds);
              },
              child: Text(
                '读卡登记中...',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // 必须设置，但会被 ShaderMask 覆盖
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),

        SizedBox(height: 16.h),

        // 提示文字
        Text(
          '请勿移动卡片',
          style: TextStyle(fontSize: 16.sp, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
