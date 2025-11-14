import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/services/external_printer_service.dart';
import '../../../data/models/external_printer_model.dart';
import '../../../core/widgets/toast.dart';

/// 外接打印机控制面板
/// 独立组件，用于检测和测试USB外接打印机
class ExternalPrinterPanel extends StatelessWidget {
  const ExternalPrinterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保服务已注册
    ExternalPrinterService service;
    try {
      service = Get.find<ExternalPrinterService>();
    } catch (e) {
      // 如果服务未注册，返回错误提示
      return Container(
        padding: EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
              SizedBox(height: AppTheme.spacingDefault),
              Text(
                '外接打印机服务未初始化',
                style: AppTheme.textSubtitle.copyWith(color: Colors.red),
              ),
              SizedBox(height: AppTheme.spacingS),
              Text(
                '请在main.dart中添加服务初始化',
                style: AppTheme.textCaption.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // 不再需要外层Container，因为已经在父组件中有了
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 扫描按钮
          Obx(
            () => SizedBox(
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: service.isScanning.value
                    ? null
                    : () => service.scanUsbPrinters(),
                icon: service.isScanning.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(Icons.refresh, size: 22.sp),
                label: Text(
                  service.isScanning.value ? '扫描中...' : '扫描USB设备',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // 设备列表（使用Expanded填充剩余空间）
          Expanded(
            child: Obx(() {
              if (service.isScanning.value) {
                return _buildScanningState();
              }

              if (service.detectedPrinters.isEmpty) {
                return _buildEmptyState();
              }

              return _buildDeviceList(service);
            }),
          ),
        ],
      ),
    );
  }

  /// 扫描中状态
  Widget _buildScanningState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50.w,
            height: 50.h,
            child: CircularProgressIndicator(
              strokeWidth: 4.w,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            '正在扫描USB设备...',
            style: TextStyle(
              fontSize: 17.sp,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.usb_off, size: 64.sp, color: const Color(0xFFCCCCCC)),
          SizedBox(height: 24.h),
          Text(
            '未检测到USB打印机',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '请连接USB打印机后点击扫描',
            style: TextStyle(fontSize: 15.sp, color: const Color(0xFFCCCCCC)),
          ),
          SizedBox(height: 8.h),
          Text(
            '支持：Epson、芯烨、佳博等品牌',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFFCCCCCC),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 设备列表
  Widget _buildDeviceList(ExternalPrinterService service) {
    return ListView.separated(
      itemCount: service.detectedPrinters.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final device = service.detectedPrinters[index];
        return _buildDeviceCard(device, service);
      },
    );
  }

  /// 设备卡片
  Widget _buildDeviceCard(
    ExternalPrinterDevice device,
    ExternalPrinterService service,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        color: device.isConnected
            ? const Color(0xFFF3E5F5)
            : AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: device.isConnected
              ? const Color(0xFF9C27B0)
              : AppTheme.borderColor,
          width: 2.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 设备名称和状态
          Row(
            children: [
              Icon(
                Icons.print,
                size: 24.sp,
                color: device.isConnected
                    ? const Color(0xFF9C27B0)
                    : AppTheme.textTertiary,
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  device.displayName,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: device.isConnected
                      ? const Color(0xFF9C27B0)
                      : AppTheme.textTertiary,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
                child: Text(
                  device.isConnected ? '已连接' : '未连接',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // 设备信息
          _buildDeviceInfo('厂商', device.manufacturer),
          SizedBox(height: 8.h),
          _buildDeviceInfo('USB ID', device.usbIdentifier),
          if (device.serialNumber != null) ...[
            SizedBox(height: 8.h),
            _buildDeviceInfo('序列号', device.serialNumber!),
          ],

          SizedBox(height: 16.h),

          // 操作按钮
          Obx(() {
            final isSelected =
                service.selectedPrinter.value?.deviceId == device.deviceId;
            final isPrinting = service.isPrinting.value && isSelected;

            return Row(
              children: [
                // 授权按钮
                if (!isSelected)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: device.isConnected
                          ? () => service.requestPermission(device)
                          : null,
                      icon: Icon(Icons.check_circle_outline, size: 20.sp),
                      label: Text(
                        '授权使用',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // 测试打印按钮
                if (isSelected) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isPrinting
                          ? null
                          : () => _testPrint(device, service),
                      icon: isPrinting
                          ? SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(Icons.print, size: 20.sp),
                      label: Text(
                        isPrinting ? '打印中...' : '测试打印',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingM),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 20.sp, color: Colors.white),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 设备信息行
  Widget _buildDeviceInfo(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 75.w,
          child: Text(
            '$label：',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 测试打印
  Future<void> _testPrint(
    ExternalPrinterDevice device,
    ExternalPrinterService service,
  ) async {
    final result = await service.testPrint(device);

    if (result.success) {
      Toast.success(message: '外接打印机测试通过');
    } else {
      Toast.error(message: '打印失败: ${result.message}');
    }
  }
}
