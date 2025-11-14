import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/external_card_reader_model.dart';

/// 读卡器设备列表项组件
/// 用于在设备列表中显示单个外置读卡器设备的信息
class CardReaderDeviceListItem extends StatelessWidget {
  final ExternalCardReaderDevice device;
  final bool isSelected;
  final bool isHighlighted; // 是否高亮显示（新设备）
  final bool isReading; // 是否为刷卡设备（绿色高亮）
  final VoidCallback? onTap;

  const CardReaderDeviceListItem({
    super.key,
    required this.device,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isReading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: isReading
              ? const Color(0xFFF0FFF4) // 刷卡设备：浅绿色背景
              : isSelected
              ? AppTheme.infoBgColor
              : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(
            color: _getBorderColor(),
            width: (isReading || isHighlighted) ? 3.w : 2.w, // 刷卡或新设备时边框更粗
          ),
          boxShadow: isReading
              ? [
                  BoxShadow(
                    color: AppTheme.successColor.withValues(alpha: 0.3), // 绿色阴影
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : isHighlighted
              ? [
                  BoxShadow(
                    color: AppTheme.infoColor.withValues(alpha: 0.3), // 蓝色阴影
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备名称和状态行
            Row(
              children: [
                // 设备图标
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(),
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusDefault,
                    ),
                  ),
                  child: Icon(Icons.nfc, size: 24.sp, color: _getIconColor()),
                ),
                SizedBox(width: AppTheme.spacingM),

                // 设备名称
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.displayName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      _buildStatusChip(),
                    ],
                  ),
                ),

                // 选中指示器
                if (isSelected)
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: const BoxDecoration(
                      color: AppTheme.successColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 16.sp, color: Colors.white),
                  ),

                // 新设备标识
                if (isHighlighted && !isSelected)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor,
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 16.h),

            // 设备详细信息
            _buildInfoRow('厂商', device.manufacturer),
            SizedBox(height: 8.h),
            _buildInfoRow('USB ID', device.usbIdentifier),

            // 可选信息
            if (device.model != null) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('型号', device.model!),
            ],
            if (device.specifications != null) ...[
              SizedBox(height: 8.h),
              _buildInfoRow('规格', device.specifications!),
            ],
          ],
        ),
      ),
    );
  }

  /// 状态标签
  Widget _buildStatusChip() {
    Color bgColor;
    Color textColor;
    String statusText;

    if (isReading) {
      // 刷卡中状态（最高优先级）
      bgColor = AppTheme.successColor.withValues(alpha: 0.15);
      textColor = AppTheme.successColor;
      statusText = '读卡中';
    } else if (device.isConnected) {
      bgColor = AppTheme.successColor.withValues(alpha: 0.1);
      textColor = AppTheme.successColor;
      statusText = '已连接';
    } else {
      bgColor = AppTheme.textTertiary.withValues(alpha: 0.1);
      textColor = AppTheme.textTertiary;
      statusText = '未连接';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// 信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
          ),
        ),
        SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 获取边框颜色
  Color _getBorderColor() {
    if (isReading) {
      return AppTheme.successColor; // 刷卡设备用绿色（最高优先级）
    }
    if (isHighlighted) {
      return AppTheme.infoColor; // 新设备用蓝色高亮
    }
    if (isSelected) {
      return const Color(0xFF91D5FF); // 选中用浅蓝色
    }
    if (device.isConnected) {
      return AppTheme.borderColor; // 已连接用灰色
    }
    return AppTheme.borderColor; // 未连接用浅灰色
  }

  /// 获取图标背景色
  Color _getIconBackgroundColor() {
    if (isHighlighted) {
      return AppTheme.infoColor.withValues(alpha: 0.1);
    }
    if (isSelected) {
      return AppTheme.successColor.withValues(alpha: 0.1);
    }
    return AppTheme.backgroundGrey;
  }

  /// 获取图标颜色
  Color _getIconColor() {
    if (isHighlighted) {
      return AppTheme.infoColor;
    }
    if (isSelected) {
      return AppTheme.successColor;
    }
    return AppTheme.textTertiary;
  }
}
