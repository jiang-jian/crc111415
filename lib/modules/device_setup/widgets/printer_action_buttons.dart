import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/device_setup_controller.dart';

/// 打印机操作按钮组件
/// 包括：重新检测按钮、测试打印按钮、状态提示、错误提示
class PrinterActionButtons extends StatelessWidget {
  const PrinterActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeviceSetupController>();

    return Obx(() {
      final checkStatus = controller.printerCheckStatus.value;
      final testStatus = controller.printerTestStatus.value;
      final isPrinterReady = checkStatus == 'ready';
      final isTesting = testStatus == 'testing';

      return Column(
        children: [
          // 重新检测按钮
          if (checkStatus == 'error' ||
              checkStatus == 'warning' ||
              checkStatus == 'ready')
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: checkStatus == 'checking'
                    ? null
                    : controller.checkPrinterStatus,
                icon: Icon(Icons.refresh, size: 18.sp),
                label: Text(
                  '重新检测',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  foregroundColor: AppTheme.infoColor,
                  side: const BorderSide(color: AppTheme.infoColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusDefault,
                    ),
                  ),
                ),
              ),
            ),

          if (checkStatus == 'error' ||
              checkStatus == 'warning' ||
              checkStatus == 'ready')
            SizedBox(height: 12.h),

          // 测试打印按钮
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: isPrinterReady && !isTesting
                  ? controller.testPrintReceipt
                  : null,
              icon: isTesting
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.print, size: 20.sp),
              label: Text(
                isTesting ? '正在打印...' : '测试打印',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // 状态提示
          if (!isPrinterReady && checkStatus != 'checking')
            Container(
              margin: EdgeInsets.only(top: 12.h),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppTheme.warningBgColor,
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusMedium,
                ),
                border: Border.all(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: const Color(0xFFF39C12),
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      '请先确保打印机状态正常',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFF39C12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 错误提示
          if (controller.errorMessage.value.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 12.h),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppTheme.errorBgColor,
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusMedium,
                ),
                border: Border.all(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16.sp,
                    color: const Color(0xFFE74C3C),
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFE74C3C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
