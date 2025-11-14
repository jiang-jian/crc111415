import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'setup_progress_indicator.dart';

/// 设备设置页面通用布局组件
class DeviceSetupLayout extends StatelessWidget {
  /// 当前步骤 (1-3)
  final int currentStep;

  /// 页面标题
  final String title;

  /// 状态列表部分
  final Widget statusSection;

  /// 操作说明部分
  final Widget? instructionsSection;

  /// 操作按钮部分
  final Widget actionButtons;

  /// 识别状态部分（可选）
  final Widget? recognitionStatus;

  /// 底部按钮部分
  final Widget bottomButtons;

  const DeviceSetupLayout({
    super.key,
    required this.currentStep,
    required this.title,
    required this.statusSection,
    this.instructionsSection,
    required this.actionButtons,
    this.recognitionStatus,
    required this.bottomButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardColor,
      child: Column(
        children: [
          // 顶部固定区域
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 900.w),
                child: Column(
                  children: [
                    // 标题
                    Text(
                      '硬件配置',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // 进度指示器
                    SetupProgressIndicator(currentStep: currentStep),

                    SizedBox(height: 32.h),

                    // 设备标题
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 中间可滚动区域
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 900.w),
                  child: Column(
                    children: [
                      SizedBox(height: 24.h),

                      // 状态列表
                      statusSection,

                      SizedBox(height: 20.h),

                      // 操作说明（可选）
                      if (instructionsSection != null) ...[
                        instructionsSection!,
                        SizedBox(height: 16.h),
                      ],

                      // 操作按钮
                      actionButtons,

                      SizedBox(height: 20.h),

                      // 识别状态（可选）
                      if (recognitionStatus != null) recognitionStatus!,

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 底部固定区域
          Container(
            padding: EdgeInsets.fromLTRB(40.w, 16.h, 40.w, 24.h),
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
