import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/services/external_card_reader_service.dart';
import '../../../data/models/external_card_reader_model.dart';
import '../widgets/card_reader_device_list_item.dart';
import '../../../app/theme/app_theme.dart';

class ExternalCardReaderView extends StatelessWidget {
  const ExternalCardReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    ExternalCardReaderService service;
    try {
      service = Get.find<ExternalCardReaderService>();
    } catch (e) {
      service = Get.put(ExternalCardReaderService());
      service.init();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Obx(() {
        final cardData = service.cardData.value;
        final hasError = service.lastError.value != null;
        final selectedDevice = service.selectedReader.value;

        // 🔧 修复闪烁: 移除 isReading 对状态的影响
        // 原因: isReading 每 500ms 切换导致 UI 闪烁
        // 解决: 只根据实际结果（cardData/error）更新状态
        String cardReadStatus;
        if (selectedDevice == null) {
          cardReadStatus = 'disconnected';
        } else if (cardData != null && cardData['isValid'] == true) {
          cardReadStatus = 'success';
        } else if (hasError) {
          cardReadStatus = 'failed';
        } else {
          cardReadStatus = 'waiting';
        }

        return _buildThreeColumnLayout(service, cardReadStatus, selectedDevice);
      }),
    );
  }

  Widget _buildThreeColumnLayout(
    ExternalCardReaderService service,
    String cardReadStatus,
    ExternalCardReaderDevice? selectedDevice,
  ) {
    return Stack(
      children: [
        Row(
          children: [
            // 左列：设备基础信息 (43% - 进一步增加宽度)
            Expanded(
              flex: 43,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 40.h),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGrey,
                  border: Border(
                    right: BorderSide(color: AppTheme.borderColor, width: 1.w),
                  ),
                ),
                child: _buildDeviceBasicInfo(service, selectedDevice),
              ),
            ),

            // 中列：读卡器配置 (32%)
            Expanded(
              flex: 32,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 56.w, vertical: 40.h),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGrey,
                  border: Border(
                    right: BorderSide(color: AppTheme.borderColor, width: 1.w),
                  ),
                ),
                child: _buildCardReaderConfig(service, cardReadStatus),
              ),
            ),

            // 右列：扫描按钮+卡片数据 (25% - 进一步减少宽度)
            Expanded(
              flex: 25,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 40.h),
                color: Colors.white,
                child: _buildCardDataSection(service, cardReadStatus),
              ),
            ),
          ],
        ),

        // 调试日志面板（浮动在右下角）
        _buildDebugLogPanel(service),
      ],
    );
  }

  Widget _buildDeviceBasicInfo(
    ExternalCardReaderService service,
    ExternalCardReaderDevice? device,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          '设备信息',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),

        SizedBox(height: 40.h),

        // 扫描按钮
        _buildScanButton(service),

        SizedBox(height: 40.h),

        // 设备列表内容（支持多设备）
        Expanded(
          child: service.isScanning.value
              ? _buildScanningState()
              : service.detectedReaders.isEmpty
              ? _buildNoDeviceState()
              : _buildDevicesList(service),
        ),
      ],
    );
  }

  Widget _buildScanButton(ExternalCardReaderService service) {
    return Obx(
      () => SizedBox(
        height: 56.h,
        child: ElevatedButton.icon(
          onPressed: service.isScanning.value
              ? null
              : () => service.scanUsbReaders(),
          icon: service.isScanning.value
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.refresh, size: 22.sp),
          label: Text(
            service.isScanning.value ? '扫描中...' : '扫描USB设备',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50.w,
            height: 50.h,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE5B544)),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '扫描中...',
            style: TextStyle(fontSize: 16.sp, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDeviceState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 60.sp,
            color: const Color(0xFFBDC3C7),
          ),
          SizedBox(height: 16.h),
          Text(
            '未检测到设备',
            style: TextStyle(fontSize: 16.sp, color: AppTheme.textTertiary),
          ),
          SizedBox(height: 8.h),
          Text(
            '请连接USB读卡器',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFFBDC3C7)),
          ),
        ],
      ),
    );
  }

  /// 构建设备列表（支持多设备显示）
  Widget _buildDevicesList(ExternalCardReaderService service) {
    return Obx(() {
      final devices = service.detectedReaders;
      final selectedDevice = service.selectedReader.value;
      final latestDeviceId = service.latestDeviceId.value;
      final lastReadDeviceId = service.lastReadDeviceId.value; // 🔧 获取刷卡设备ID

      return ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          final isSelected = selectedDevice?.deviceId == device.deviceId;
          final isHighlighted = latestDeviceId == device.deviceId;
          final isReading = lastReadDeviceId == device.deviceId; // 🔧 判断是否为刷卡设备

          return CardReaderDeviceListItem(
            device: device,
            isSelected: isSelected,
            isHighlighted: isHighlighted,
            isReading: isReading, // 🔧 传递刷卡状态
            onTap: () {
              // 点击设备项时选择该设备
              if (device.isConnected) {
                service.selectedReader.value = device;
                service.latestDeviceId.value = null; // 清除新设备高亮
                service.lastReadDeviceId.value = null; // 🔧 清除刷卡高亮
              }
            },
          );
        },
      );
    });
  }

  Widget _buildCardReaderConfig(
    ExternalCardReaderService service,
    String cardReadStatus,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '读卡器配置',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),

        SizedBox(height: 60.h),

        _buildCardIcon(cardReadStatus),

        SizedBox(height: 56.h),

        _buildStatusText(service, cardReadStatus),

        SizedBox(height: 40.h),

        if (cardReadStatus == 'failed') _buildRetryButton(service),
      ],
    );
  }

  Widget _buildCardIcon(String cardReadStatus) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Container(
            width: 220.w,
            height: 220.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColors(cardReadStatus),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: _getGradientColors(
                    cardReadStatus,
                  )[0].withValues(alpha: 0.3),
                  blurRadius: 35,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.credit_card, size: 110.sp, color: Colors.white),
                if (cardReadStatus == 'reading')
                  Positioned(
                    bottom: 40.h,
                    child: SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3.5.w,
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

  List<Color> _getGradientColors(String status) {
    switch (status) {
      case 'success':
        return [
          AppTheme.successColor,
          AppTheme.successColor.withValues(alpha: 0.8),
        ];
      case 'failed':
      case 'disconnected':
        return [
          const Color(0xFFE74C3C),
          AppTheme.errorColor.withValues(alpha: 0.8),
        ];
      case 'reading':
      case 'waiting':
      default:
        return [AppTheme.infoColor, AppTheme.infoColor.withValues(alpha: 0.8)];
    }
  }

  Widget _buildStatusText(
    ExternalCardReaderService service,
    String cardReadStatus,
  ) {
    String text;
    Color color;
    IconData? icon;
    String? hint;

    switch (cardReadStatus) {
      case 'disconnected':
        text = '未连接外置读卡器';
        color = const Color(0xFFE74C3C);
        icon = Icons.usb_off;
        hint = '💡 请连接USB读卡器并点击【扫描USB设备】';
        break;
      case 'waiting':
      case 'reading':
        text = '请将 M1 卡片靠近外置读卡器...';
        color = AppTheme.infoColor;
        icon = Icons.contactless;
        hint = '确保卡片完全放置在读卡器感应区域';
        break;
      case 'success':
        text = '✓ 读取成功';
        color = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case 'failed':
        text = service.lastError.value ?? '读取失败，请重试';
        color = const Color(0xFFE74C3C);
        icon = Icons.error;
        // 根据错误类型给出不同的提示
        if (service.lastError.value?.contains('权限') == true) {
          hint = '💡 请在系统弹窗中允许USB访问';
        } else if (service.lastError.value?.contains('未检测') == true) {
          hint = '💡 1) 确保卡片已放置 2) 尝试调整卡片位置';
        } else if (service.lastError.value?.contains('UID') == true) {
          hint = '💡 1) 重新放置卡片 2) 检查卡片是否为M1卡';
        } else {
          hint = '💡 查看下方调试日志了解详细信息';
        }
        break;
      default:
        text = '准备读卡...';
        color = AppTheme.textTertiary;
        icon = Icons.nfc;
    }

    return Column(
      children: [
        Icon(icon, size: 42.sp, color: color),
        SizedBox(height: 18.h),
        Text(
          text,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        if (hint != null) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              hint,
              style: TextStyle(fontSize: 15.sp, color: color, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRetryButton(ExternalCardReaderService service) {
    return SizedBox(
      width: 200.w,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: () {
          service.clearCardData();
          service.lastError.value = null;
        },
        icon: Icon(Icons.refresh, size: 20.sp),
        label: Text(
          '重新读卡',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCardDataSection(
    ExternalCardReaderService service,
    String cardReadStatus,
  ) {
    return Obx(() {
      final cardData = service.cardData.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '卡片数据',
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          SizedBox(height: 40.h),

          Expanded(
            child: cardData != null && cardReadStatus == 'success'
                ? _buildCardDataDisplay(cardData, service)
                : _buildCardPlaceholder(cardReadStatus),
          ),
        ],
      );
    });
  }

  Widget _buildCardPlaceholder(String cardReadStatus) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGrey,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
          border: Border.all(color: AppTheme.borderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              cardReadStatus == 'reading'
                  ? Icons.sync
                  : Icons.credit_card_outlined,
              size: 80.sp,
              color: const Color(0xFFBDC3C7),
            ),
            SizedBox(height: 20.h),
            Text(
              cardReadStatus == 'reading' ? '正在读取卡片...' : '等待读卡',
              style: TextStyle(
                fontSize: 18.sp,
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDataDisplay(
    Map<String, dynamic> cardData,
    ExternalCardReaderService service,
  ) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGrey,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
          border: Border.all(
            color: AppTheme.successColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 5.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusSmall,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Text(
                  '读取数据',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => service.clearCardData(),
                  icon: Icon(Icons.clear, size: 20.sp),
                  tooltip: '清除数据',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppTheme.textTertiary,
                ),
              ],
            ),

            SizedBox(height: 24.h),

            _buildCardDataRow('卡片 UID', cardData['uid'] ?? '未知'),
            SizedBox(height: 18.h),
            _buildCardDataRow('卡片类型', cardData['type'] ?? '未知'),
            if (cardData['capacity'] != null) ...[
              SizedBox(height: 18.h),
              _buildCardDataRow('卡片容量', cardData['capacity'] ?? '未知'),
            ],
            SizedBox(height: 18.h),
            _buildCardDataRow('读取时间', _formatTimestamp(cardData['timestamp'])),

            if (cardData['isValid'] == true) ...[
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20.sp,
                      color: AppTheme.successColor,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '卡片验证通过',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardDataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingDefault),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '未知';
    try {
      final dateTime = DateTime.parse(timestamp.toString());
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp.toString();
    }
  }

  /// 构建调试日志面板
  Widget _buildDebugLogPanel(ExternalCardReaderService service) {
    return Positioned(
      right: 16.w,
      bottom: 16.h,
      child: Obx(() {
        final logs = service.debugLogs;
        final isExpanded = service.debugLogExpanded.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isExpanded ? 450.w : 200.w,
          height: isExpanded ? 400.h : 50.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 标题栏
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.terminal,
                      size: 18.sp,
                      color: const Color(0xFF4CAF50),
                    ),
                    SizedBox(width: AppTheme.spacingS),
                    Text(
                      '调试日志',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (isExpanded) ...[
                      // 清空按钮
                      InkWell(
                        onTap: () => service.clearLogs(),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacingM),
                    ],
                    // 展开/收起按钮
                    InkWell(
                      onTap: () => service.debugLogExpanded.value = !isExpanded,
                      child: Icon(
                        isExpanded ? Icons.expand_more : Icons.expand_less,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // 日志内容
              if (isExpanded)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(AppTheme.spacingM),
                    child: logs.isEmpty
                        ? Center(
                            child: Text(
                              '暂无日志',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white54,
                              ),
                            ),
                          )
                        : ListView.builder(
                            reverse: true,
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              final isError =
                                  log.contains('✗') ||
                                  log.contains('错误') ||
                                  log.contains('失败');
                              final isSuccess =
                                  log.contains('✓') || log.contains('成功');
                              final isWarning =
                                  log.contains('⚠') || log.contains('警告');

                              Color textColor = Colors.white70;
                              if (isError) {
                                textColor = const Color(0xFFFF5252);
                              } else if (isSuccess) {
                                textColor = const Color(0xFF4CAF50);
                              } else if (isWarning) {
                                textColor = const Color(0xFFFFA726);
                              }

                              return Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: Text(
                                  log,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: textColor,
                                    fontFamily: 'monospace',
                                    height: 1.4,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
