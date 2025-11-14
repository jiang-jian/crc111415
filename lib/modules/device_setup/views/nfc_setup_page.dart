import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/device_setup_controller.dart';
import '../widgets/nfc_device_status.dart';
import '../widgets/nfc_config_split_layout.dart';
import '../widgets/nfc_left_config_section.dart';
import '../widgets/nfc_right_data_section.dart';
import '../widgets/device_setup_layout.dart';

/// NFC 读卡器设置页面
class NfcSetupPage extends GetView<DeviceSetupController> {
  const NfcSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 进入页面时自动检测 NFC
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.nfcCheckStatus.value.isEmpty) {
        controller.enterCardReaderSetup();
      }
    });

    return DeviceSetupLayout(
      currentStep: 2,
      title: 'NFC 读卡器配置',
      statusSection: Obx(() => _buildDeviceStatusSection()),
      actionButtons: Obx(() => _buildMainContent()),
      bottomButtons: Obx(() => _buildBottomButtons()),
    );
  }

  /// 构建设备状态区域（如果NFC不可用或未启用时显示）
  Widget _buildDeviceStatusSection() {
    final status = controller.nfcCheckStatus.value;

    // 只在检测中、不可用或未启用时显示
    if (status.isEmpty || status == 'available') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        children: [
          NfcDeviceStatus(
            status: status,
            errorMessage: controller.errorMessage.value,
            onEnableNfc: status == 'disabled'
                ? controller.openNfcSettings
                : null,
          ),
          // 如果是未启用状态，显示重新检测按钮
          if (status == 'disabled') ...[
            SizedBox(height: 16.h),
            SizedBox(
              height: 48.h, // 设置固定高度
              child: TextButton.icon(
                onPressed: controller.recheckNfc,
                icon: Icon(Icons.refresh, size: 18.sp),
                label: Text(
                  '重新检测',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.2, // 设置行高
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建主要内容区域（左右分栏布局）
  Widget _buildMainContent() {
    final nfcStatus = controller.nfcCheckStatus.value;
    final cardStatus = controller.cardReadStatus.value;

    // 只有在 NFC 可用时才显示左右分栏布局
    if (nfcStatus != 'available' || cardStatus.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 600.h, // 固定高度，确保一屏显示
      child: NfcConfigSplitLayout(
        leftSection: NfcLeftConfigSection(
          cardReadStatus: cardStatus,
          errorMessage: controller.errorMessage.value,
          onRetry: controller.retryReadCard,
        ),
        rightSection: NfcRightDataSection(
          cardData: controller.cardData.value,
          cardReadStatus: cardStatus,
        ),
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButtons() {
    final isCompleted = controller.cardReaderCompleted.value;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600.w),
        child: Column(
          children: [
            // 下一步按钮
            SizedBox(
              width: double.infinity,
              height: 56.h, // 增加高度
              child: ElevatedButton(
                onPressed: isCompleted ? controller.nextStep : null,
                child: Text(
                  '下一步',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.2, // 设置行高
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // 稍后设置链接
            TextButton(
              onPressed: controller.skipCurrentStep,
              child: Text(
                '稍后设置"硬件"',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppTheme.infoColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
