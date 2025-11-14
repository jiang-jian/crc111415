import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// NFC 设备状态显示组件
class NfcDeviceStatus extends StatelessWidget {
  final String status;
  final String? errorMessage;
  final VoidCallback? onEnableNfc;

  const NfcDeviceStatus({
    super.key,
    required this.status,
    this.errorMessage,
    this.onEnableNfc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
        border: Border.all(color: _getBorderColor(), width: 2),
      ),
      child: Column(
        children: [
          _buildStatusIcon(),
          SizedBox(height: AppTheme.spacingDefault),
          _buildStatusText(),
          if (status == 'disabled' && onEnableNfc != null) ...[
            SizedBox(height: AppTheme.spacingDefault),
            _buildEnableButton(),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case 'checking':
        return AppTheme.infoBgColor;
      case 'available':
        return AppTheme.successBgColor;
      case 'unsupported':
      case 'unavailable':
        return AppTheme.errorBgColor;
      case 'disabled':
        return AppTheme.warningBgColor;
      default:
        return AppTheme.backgroundGrey;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case 'checking':
        return AppTheme.infoColor;
      case 'available':
        return AppTheme.successColor;
      case 'unsupported':
      case 'unavailable':
        return AppTheme.errorColor;
      case 'disabled':
        return AppTheme.warningColor;
      default:
        return AppTheme.backgroundDisabled;
    }
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (status) {
      case 'checking':
        icon = Icons.sync;
        color = AppTheme.infoColor;
        break;
      case 'available':
        icon = Icons.check_circle;
        color = AppTheme.successColor;
        break;
      case 'unsupported':
        icon = Icons.block;
        color = AppTheme.errorColor;
        break;
      case 'unavailable':
        icon = Icons.error;
        color = AppTheme.errorColor;
        break;
      case 'disabled':
        icon = Icons.settings;
        color = AppTheme.warningColor;
        break;
      default:
        icon = Icons.help_outline;
        color = AppTheme.textTertiary;
    }

    return Container(
      width: 64.w,
      height: 64.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 32.sp, color: color),
    );
  }

  Widget _buildStatusText() {
    String text;
    Color color;

    switch (status) {
      case 'checking':
        text = '正在检测设备...';
        color = AppTheme.infoColor;
        break;
      case 'available':
        text = '检测到可用设备';
        color = AppTheme.successColor;
        break;
      case 'unsupported':
        text = '当前设备不支持 NFC 功能';
        color = AppTheme.errorColor;
        break;
      case 'disabled':
        text = 'NFC 功能未启用';
        color = AppTheme.warningColor;
        break;
      case 'unavailable':
        text = errorMessage ?? '未检测到可用设备';
        color = AppTheme.errorColor;
        break;
      default:
        text = '准备检测...';
        color = AppTheme.textTertiary;
    }

    return Text(
      text,
      style: AppTheme.textSubtitle.copyWith(
        fontWeight: FontWeight.w500,
        color: color,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEnableButton() {
    return SizedBox(
      height: 52.h, // 增加高度
      child: ElevatedButton.icon(
        onPressed: onEnableNfc,
        icon: Icon(Icons.settings, size: 18.sp),
        label: Text(
          '打开 NFC 设置',
          style: AppTheme.textSubtitle.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.2, // 设置行高
          ),
        ),
      ),
    );
  }
}
