import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/services/sunmi_printer_service.dart';
import 'printer_status_translation.dart';

/// 打印机状态显示组件
/// 根据不同状态显示不同的UI：
/// - Status.READY（正常）-> 绿色✓
/// - Status.ERR_*（错误）-> 红色✗
/// - Status.WARN_*（警告）-> 黄色⚠
class PrinterStatusDisplay extends StatelessWidget {
  final PrinterStatusInfo? statusInfo;
  final bool isChecking;

  const PrinterStatusDisplay({
    super.key,
    this.statusInfo,
    this.isChecking = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return _buildCheckingStatus();
    }

    if (statusInfo == null) {
      return _buildUnknownStatus();
    }

    switch (statusInfo!.status) {
      case PrinterStatus.ready:
        return _buildReadyStatus();
      case PrinterStatus.error:
        return _buildErrorStatus();
      case PrinterStatus.warning:
        return _buildWarningStatus();
      case PrinterStatus.unknown:
        return _buildUnknownStatus();
    }
  }

  /// 检测中状态（蓝色加载）
  Widget _buildCheckingStatus() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.infoBgColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
        border: Border.all(color: AppTheme.infoColor, width: 2.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.5.w,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.infoColor),
            ),
          ),
          SizedBox(width: AppTheme.spacingDefault),
          Text(
            '正在检测打印机状态...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.infoColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 就绪状态（绿色✓）- Status.READY
  Widget _buildReadyStatus() {
    final detailInfo = statusInfo?.detailInfo;

    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FFED),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.successColor, width: 2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态标题行
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: const BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 30.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppTheme.spacingDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '打印机正常',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '可以进行打印测试',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 打印机详情信息（对应demo的【打印机详情】显示）
          if (detailInfo != null) ...[
            SizedBox(height: 16.h),
            Divider(
              color: AppTheme.successColor.withValues(alpha: 0.2),
              height: 1.h,
            ),
            SizedBox(height: 14.h),
            _buildDetailRow('ID', detailInfo.printerId ?? '--'),
            SizedBox(height: 10.h),
            _buildDetailRow('名称', detailInfo.printerName ?? '--'),
            SizedBox(height: 10.h),
            _buildDetailRow('状态', detailInfo.printerStatus ?? '--'),
            SizedBox(height: 10.h),
            _buildDetailRow('类型', detailInfo.printerType ?? '--'),
            SizedBox(height: 10.h),
            _buildDetailRow('规格', detailInfo.printerPaper ?? '--'),
          ],
        ],
      ),
    );
  }

  /// 详情行 - 支持中文翻译（增大字体）
  Widget _buildDetailRow(String label, String value) {
    // 对状态和类型字段添加中文翻译
    String displayValue = value;
    if (label == '状态' || label == '类型') {
      displayValue = PrinterStatusTranslation.formatWithTranslation(value);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 55.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '：',
          style: TextStyle(fontSize: 15.sp, color: AppTheme.textTertiary),
        ),
        Expanded(
          child: Text(
            displayValue,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 错误状态（红色✗）- Status.ERR_*, Status.OFFLINE, Status.COMM
  Widget _buildErrorStatus() {
    final detailInfo = statusInfo?.detailInfo;

    return Container(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        color: AppTheme.errorBgColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: const Color(0xFFE74C3C), width: 2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态标题行
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cancel, size: 24.sp, color: Colors.white),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '打印机异常',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE74C3C),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _getErrorMessage(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 打印机详情信息（对应demo的【打印机详情】显示）
          if (detailInfo != null) ...[
            SizedBox(height: 12.h),
            Divider(
              color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
              height: 1.h,
            ),
            SizedBox(height: 10.h),
            _buildDetailRow('ID', detailInfo.printerId ?? '--'),
            SizedBox(height: 6.h),
            _buildDetailRow('名称', detailInfo.printerName ?? '--'),
            SizedBox(height: 6.h),
            _buildDetailRow('状态', detailInfo.printerStatus ?? '--'),
            SizedBox(height: 6.h),
            _buildDetailRow('类型', detailInfo.printerType ?? '--'),
            SizedBox(height: 6.h),
            _buildDetailRow('规格', detailInfo.printerPaper ?? '--'),
          ],
        ],
      ),
    );
  }

  /// 警告状态（黄色⚠）- Status.WARN_*
  Widget _buildWarningStatus() {
    final detailInfo = statusInfo?.detailInfo;

    return Container(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE6),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: const Color(0xFFF39C12), width: 2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态标题行
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFF39C12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 24.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '打印机警告',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF39C12),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      statusInfo?.message ?? '打印机有警告信息',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 打印机详情信息（对应demo的【打印机详情】显示）
          if (detailInfo != null) ...[
            SizedBox(height: 12.h),
            Divider(
              color: const Color(0xFFF39C12).withValues(alpha: 0.2),
              height: 1.h,
            ),
            SizedBox(height: 10.h),
            _buildDetailRow('ID', detailInfo.printerId ?? '--'),
            SizedBox(height: 6.h),
            _buildDetailRow('名称', detailInfo.printerName ?? '--'),
            SizedBox(height: 6.h),
            _buildDetailRow('状态', detailInfo.printerStatus ?? '--'),
            SizedBox(height: 6.h),
            _buildDetailRow('类型', detailInfo.printerType ?? '--'),
            SizedBox(height: 6.h),
            _buildDetailRow('规格', detailInfo.printerPaper ?? '--'),
          ],
        ],
      ),
    );
  }

  /// 未知状态（灰色？）
  Widget _buildUnknownStatus() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
        border: Border.all(color: AppTheme.borderColor, width: 2.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: const BoxDecoration(
              color: AppTheme.textTertiary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.help_outline, size: 32.sp, color: Colors.white),
          ),
          SizedBox(width: 20.w),
          Text(
            '未检测到打印机',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取错误消息（根据不同错误类型返回详细说明）
  String _getErrorMessage() {
    final message = statusInfo?.message ?? '打印机发生错误';
    final rawStatus = statusInfo?.rawStatus ?? '';

    if (rawStatus.contains('PAPER_OUT') || message.contains('缺纸')) {
      return '打印机缺纸，请补充打印纸';
    } else if (rawStatus.contains('PAPER_JAM') || message.contains('堵纸')) {
      return '打印机堵纸，请检查纸张';
    } else if (rawStatus.contains('PAPER_MISMATCH')) {
      return '打印纸不匹配打印机';
    } else if (rawStatus.contains('OFFLINE')) {
      return '打印机离线或故障';
    } else if (rawStatus.contains('COMM')) {
      return '打印机通信异常';
    }

    return message;
  }
}
