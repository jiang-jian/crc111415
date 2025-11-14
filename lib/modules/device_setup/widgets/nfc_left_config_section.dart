import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// NFC配置左侧区域组件
class NfcLeftConfigSection extends StatelessWidget {
  final String cardReadStatus;
  final String? errorMessage;
  final VoidCallback onRetry;

  const NfcLeftConfigSection({
    super.key,
    required this.cardReadStatus,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 标题
        Text('NFC 读卡器配置', style: AppTheme.textLarge),

        SizedBox(height: 48.h),

        // 卡片图标动画
        _buildCardIcon(),

        SizedBox(height: 48.h),

        // 读卡状态提示
        _buildStatusText(),

        SizedBox(height: 32.h),

        // 操作按钮（失败时显示）
        if (cardReadStatus == 'failed') _buildRetryButton(),
      ],
    );
  }

  Widget _buildCardIcon() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Container(
            width: 200.w,
            height: 200.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColors(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
              boxShadow: [
                BoxShadow(
                  color: _getGradientColors()[0].withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.credit_card, size: 100.sp, color: Colors.white),
                if (cardReadStatus == 'reading')
                  Positioned(
                    bottom: 40.h,
                    child: SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3.w,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getGradientColors() {
    switch (cardReadStatus) {
      case 'success':
        return [
          AppTheme.successColor,
          AppTheme.successColor.withValues(alpha: 0.8),
        ];
      case 'failed':
        return [
          AppTheme.errorColor,
          AppTheme.errorColor.withValues(alpha: 0.8),
        ];
      case 'reading':
      case 'waiting':
      default: // reading, waiting 或其他状态都显示蓝色（表示等待）
        return [AppTheme.infoColor, AppTheme.infoColor.withValues(alpha: 0.8)];
    }
  }

  Widget _buildStatusText() {
    String text;
    Color color;
    IconData? icon;

    switch (cardReadStatus) {
      case 'waiting':
      case 'reading':
        text = '请将 M1 卡片靠近收银台读卡器...';
        color = AppTheme.infoColor;
        icon = Icons.contactless;
        break;
      case 'success':
        text = '✓ 读取成功';
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case 'failed':
        text = errorMessage ?? '读取失败，请重试';
        color = AppTheme.errorColor;
        icon = Icons.error;
        break;
      default:
        text = '准备读卡...';
        color = AppTheme.textTertiary;
        icon = Icons.nfc;
    }

    return Column(
      children: [
        Icon(icon, size: 40.sp, color: color),
        SizedBox(height: AppTheme.spacingDefault),
        Text(
          text,
          style: AppTheme.textHeading.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: 200.w,
      height: 56.h, // 增加高度以完整显示文字
      child: ElevatedButton.icon(
        onPressed: onRetry,
        icon: Icon(Icons.refresh, size: 20.sp),
        label: Text(
          '重新读卡',
          style: AppTheme.textSubtitle.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2, // 设置行高
          ),
        ),
      ),
    );
  }
}
