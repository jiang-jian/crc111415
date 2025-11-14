import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'setup_progress_indicator.dart';

/// 打印机设置页面专用布局
/// 特点：全宽3列布局，避免maxWidth限制
class PrinterSetupLayout extends StatelessWidget {
  /// 页面标题
  final String title;

  /// 主内容区域（3列布局）
  final Widget mainContent;

  /// 识别状态（可选）
  final Widget? recognitionStatus;

  /// 底部按钮
  final Widget bottomButtons;

  const PrinterSetupLayout({
    super.key,
    required this.title,
    required this.mainContent,
    this.recognitionStatus,
    required this.bottomButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardColor,
      child: Column(
        children: [
          // 顶部固定区域（保持居中和最大宽度）
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 40.w,
              vertical: AppTheme.spacingL,
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 900.w),
                child: Column(
                  children: [
                    // 标题
                    Text('硬件配置', style: AppTheme.textDisplay),

                    SizedBox(height: AppTheme.spacingL),

                    // 进度指示器
                    const SetupProgressIndicator(currentStep: 3),

                    SizedBox(height: AppTheme.spacingXL),

                    // 设备标题
                    Text(title, style: AppTheme.textLarge),
                  ],
                ),
              ),
            ),
          ),

          // 中间全宽区域（使用Flexible布局，充分利用空间）
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 40.w,
                vertical: AppTheme.spacingL,
              ),
              child: Column(
                children: [
                  // 主内容（3列布局）- 使用Expanded填充可用空间
                  Expanded(child: mainContent),

                  SizedBox(height: AppTheme.spacingL),

                  // 识别状态（可选）
                  if (recognitionStatus != null) recognitionStatus!,

                  SizedBox(height: AppTheme.spacingL),
                ],
              ),
            ),
          ),

          // 底部固定区域
          Container(
            padding: EdgeInsets.fromLTRB(
              40.w,
              AppTheme.spacingDefault,
              40.w,
              AppTheme.spacingL,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 900.w),
                child: bottomButtons,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
