import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/device_setup_controller.dart';
import '../../../data/services/sunmi_printer_service.dart';
import '../widgets/printer_setup_layout.dart';
import '../widgets/printer_status_display.dart';
import '../widgets/printer_instructions_panel.dart';
import '../widgets/printer_action_buttons.dart';
import '../widgets/draggable_log_panel.dart';

/// 打印机设置页面 - 内置打印机配置
/// 只保留内置打印机配置功能
/// 外置打印机已迁移至【设置】模块
class PrinterSetupPage extends GetView<DeviceSetupController> {
  const PrinterSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主要内容
        PrinterSetupLayout(
          title: '打印机',
          mainContent: Obx(() => _buildMainContent()),
          recognitionStatus: Obx(() => _buildRecognitionStatus()),
          bottomButtons: Obx(() => _buildBottomButtons()),
        ),

        // 可拖动的日志面板（悬浮在最右侧）
        const DraggableLogPanel(),
      ],
    );
  }

  /// 主内容区域 - 2列布局（操作提示 + 内置打印机）
  Widget _buildMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 第1列：操作提示（20%宽度，紧凑显示）
        Expanded(flex: 20, child: _buildInstructionsPanel()),

        SizedBox(width: AppTheme.spacingXL),

        // 第2列：内置打印机（80%宽度，居中显示）
        Expanded(
          flex: 80,
          child: _buildBuiltInPrinterPanel(), // 打印机信息面板居中
        ),
      ],
    );
  }

  /// 第1列：操作提示
  Widget _buildInstructionsPanel() {
    return const PrinterInstructionsPanel();
  }

  /// 第2列：内置打印机面板（状态信息和按钮居中）
  Widget _buildBuiltInPrinterPanel() {
    final printerService = Get.find<SunmiPrinterService>();
    final checkStatus = controller.printerCheckStatus.value;

    return Center(
      // 整体居中
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
        crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
        children: [
          // 打印机状态显示（居中）
          Center(
            child: PrinterStatusDisplay(
              statusInfo: printerService.printerStatus.value,
              isChecking: checkStatus == 'checking',
            ),
          ),

          SizedBox(height: 24.h),

          // 操作按钮（居中）
          const Center(child: PrinterActionButtons()),
        ],
      ),
    );
  }

  /// 识别状态（测试成功后显示）
  Widget _buildRecognitionStatus() {
    final testStatus = controller.printerTestStatus.value;

    if (testStatus != 'success') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          width: 56.w,
          height: 56.h,
          decoration: const BoxDecoration(
            color: AppTheme.successColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 32.sp, color: Colors.white),
        ),
        SizedBox(height: 12.h),
        Text(
          '测试通过',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.successColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '打印机配置成功',
          style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  /// 底部按钮
  Widget _buildBottomButtons() {
    final isCompleted = controller.printerCompleted.value;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600.w),
        child: Column(
          children: [
            // 下一步按钮
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: isCompleted ? controller.completeSetup : null,
                child: Text(
                  '下一步',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // 稍后设置链接
            TextButton(
              onPressed: controller.skipCurrentStep,
              child: Text('稍后设置"硬件"'),
            ),
          ],
        ),
      ),
    );
  }
}
