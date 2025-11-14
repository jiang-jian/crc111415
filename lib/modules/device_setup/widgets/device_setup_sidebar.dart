import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/device_setup_controller.dart';

/// 设备初始化侧边栏导航
class DeviceSetupSidebar extends GetView<DeviceSetupController> {
  const DeviceSetupSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      decoration: AppTheme.cardDecoration(withShadow: true),
      child: Column(
        children: [
          // 标题
          Container(
            padding: EdgeInsets.all(AppTheme.spacingL),
            decoration: AppTheme.gradientDecoration(borderRadius: 0).copyWith(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(AppTheme.borderRadiusRound),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusLarge,
                    ),
                  ),
                  child: Icon(
                    Icons.devices_other,
                    size: 24.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppTheme.spacingM),
                Text(
                  '设备初始化',
                  style: AppTheme.textTitle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),

          // 步骤列表
          Expanded(
            child: Obx(
              () => ListView(
                padding: EdgeInsets.all(AppTheme.spacingDefault),
                children: [
                  _buildStepItem(
                    icon: Icons.qr_code_scanner,
                    title: '扫码枪设置',
                    subtitle: '第一步',
                    step: DeviceSetupStep.scanner,
                    isCompleted: controller.scannerCompleted.value,
                  ),
                  SizedBox(height: AppTheme.spacingM),
                  _buildStepItem(
                    icon: Icons.credit_card,
                    title: '读卡器设置',
                    subtitle: '第二步',
                    step: DeviceSetupStep.cardReader,
                    isCompleted: controller.cardReaderCompleted.value,
                  ),
                  SizedBox(height: AppTheme.spacingM),
                  _buildStepItem(
                    icon: Icons.print,
                    title: '打印机设置',
                    subtitle: '第三步',
                    step: DeviceSetupStep.printer,
                    isCompleted: controller.printerCompleted.value,
                  ),
                  SizedBox(height: AppTheme.spacingM),
                  _buildStepItem(
                    icon: Icons.check_circle,
                    title: '设置完成',
                    subtitle: '完成',
                    step: DeviceSetupStep.completed,
                    isCompleted: false,
                  ),
                ],
              ),
            ),
          ),

          // 底部提示
          Container(
            padding: EdgeInsets.all(AppTheme.spacingDefault),
            margin: EdgeInsets.all(AppTheme.spacingDefault),
            decoration: AppTheme.statusContainerDecoration(
              type: 'info',
              borderRadius: AppTheme.borderRadiusLarge,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20.sp,
                  color: AppTheme.infoColor,
                ),
                SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    '请按顺序完成设备设置',
                    style: AppTheme.textCaption.copyWith(
                      color: AppTheme.infoColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建步骤项
  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required DeviceSetupStep step,
    required bool isCompleted,
  }) {
    final isCurrent = controller.currentStep.value == step;
    final isActive = isCurrent || isCompleted;

    return InkWell(
      onTap: () {
        // 可以添加点击切换步骤的逻辑
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingDefault),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppTheme.warningBgColor
              : isCompleted
              ? AppTheme.infoBgColor
              : AppTheme.backgroundGrey,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(
            color: isCurrent
                ? AppTheme.primaryColor
                : isCompleted
                ? AppTheme.infoColor
                : Colors.transparent,
            width: 2.w,
          ),
        ),
        child: Row(
          children: [
            // 图标或状态
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppTheme.primaryColor
                    : isCompleted
                    ? AppTheme.successColor
                    : AppTheme.backgroundDisabled,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                size: 24.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(width: AppTheme.spacingM),
            // 文字信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.textBody.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? AppTheme.textPrimary
                          : AppTheme.textTertiary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXS),
                  Text(
                    subtitle,
                    style: AppTheme.textCaption.copyWith(
                      color: isActive
                          ? AppTheme.textSecondary
                          : AppTheme.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
            // 箭头或勾选
            if (isCurrent)
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppTheme.primaryColor,
              )
            else if (isCompleted)
              Container(
                width: 20.w,
                height: 20.h,
                decoration: const BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 14.sp, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
