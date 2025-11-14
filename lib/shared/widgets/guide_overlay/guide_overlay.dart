import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';
import 'guide_step_model.dart';

/// 新手引导遮罩组件
/// 支持基于Rect的引导步骤
class GuideOverlay extends StatefulWidget {
  /// 引导步骤列表（基于Rect）
  final List<GuideStepConfig> steps;

  /// 完成引导的回调
  final VoidCallback onComplete;

  /// 跳过引导的回调
  final VoidCallback onSkip;

  const GuideOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<GuideOverlay> createState() => _GuideOverlayState();
}

class _GuideOverlayState extends State<GuideOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 获取当前步骤
  GuideStepConfig get _currentStep => widget.steps[_currentStepIndex];

  /// 获取目标区域
  Rect get _targetRect => _currentStep.highlightRect;

  /// 进入下一步
  void _nextStep() {
    if (_currentStepIndex < widget.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      widget.onComplete();
    }
  }

  /// 跳过引导
  void _skip() {
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    final targetRect = _targetRect;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 遮罩层（带高亮区域）
            _buildMaskLayer(targetRect),
            // 引导提示卡片
            _buildTipCard(targetRect),
            // 底部跳过按钮
            _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  /// 构建遮罩层
  Widget _buildMaskLayer(Rect targetRect) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GuideMaskPainter(
          targetRect: targetRect,
          borderRadius: _currentStep.borderRadius,
        ),
      ),
    );
  }

  /// 构建提示卡片
  Widget _buildTipCard(Rect targetRect) {
    // 计算卡片位置（默认在目标下方）
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = 180.h;
    final spacing = 16.h;

    // 判断卡片应该在目标上方还是下方
    final showBelow = targetRect.bottom + spacing + cardHeight < screenHeight;
    final top = showBelow
        ? targetRect.bottom + spacing
        : targetRect.top - cardHeight - spacing;

    // 应用自定义偏移
    final offset = _currentStep.tipOffset ?? Offset.zero;

    return Positioned(
      left: 24.w + offset.dx,
      right: 24.w - offset.dx,
      top: top + offset.dy,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              _currentStep.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            // 描述文本
            Text(
              _currentStep.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            // 步骤指示器和按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 步骤指示器
                Row(
                  children: List.generate(
                    widget.steps.length,
                    (index) => Container(
                      width: 8.w,
                      height: 8.h,
                      margin: EdgeInsets.only(right: 6.w),
                      decoration: BoxDecoration(
                        color: index == _currentStepIndex
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // 我知道了按钮
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                  ),
                  child: Text('我知道了', style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建跳过按钮
  Widget _buildSkipButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 60.h,
      child: Center(
        child: ElevatedButton(
          onPressed: _skip,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
          ),
          child: Text(
            '跳过引导',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

/// 遮罩画笔（绘制半透明遮罩并挖空高亮区域）
class _GuideMaskPainter extends CustomPainter {
  final Rect targetRect;
  final double borderRadius;

  _GuideMaskPainter({required this.targetRect, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制半透明背景
    final maskPaint = Paint()..color = Colors.black.withValues(alpha: .7);

    // 创建整个屏幕的路径
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 创建高亮区域的路径（带边距和圆角）
    final padding = 8.0;
    final highlightRect = Rect.fromLTRB(
      targetRect.left - padding,
      targetRect.top - padding,
      targetRect.right + padding,
      targetRect.bottom + padding,
    );

    final highlightPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(highlightRect, Radius.circular(borderRadius)),
      );

    // 从背景中减去高亮区域
    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      highlightPath,
    );

    canvas.drawPath(finalPath, maskPaint);

    // 绘制高亮区域边框
    final borderPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: .8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(highlightRect, Radius.circular(borderRadius)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GuideMaskPainter oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        borderRadius != oldDelegate.borderRadius;
  }
}
