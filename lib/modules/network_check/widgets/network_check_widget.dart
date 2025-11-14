import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/network_check_controller.dart';
import '../../../data/models/network_status.dart';
import '../../../l10n/app_localizations.dart';

class NetworkCheckWidget extends GetView<NetworkCheckController> {
  const NetworkCheckWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 标题
        Text(
          l10n.networkAutoCheck,
          style: AppTheme.textTitle.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacingXL),

        // 连接状态区域
        Expanded(
          child: Container(
            padding: EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGrey,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 外网连接状态
                _buildCheckItem(
                  label: l10n.externalConnectionStatus,
                  statusObservable: controller.externalConnectionStatus,
                ),
                SizedBox(height: AppTheme.spacingDefault),
                // 中心服务器连接状态
                _buildCheckItem(
                  label: l10n.centerServerConnectionStatus,
                  statusObservable: controller.centerServerConnectionStatus,
                ),
                SizedBox(height: AppTheme.spacingDefault),
                // 外网Ping检测
                _buildCheckItem(
                  label: l10n.externalPingResult,
                  statusObservable: controller.externalPingStatus,
                  showLatency: true,
                ),
                SizedBox(height: AppTheme.spacingDefault),

                // DNS服务Ping
                _buildCheckItem(
                  label: l10n.dnsPingResult,
                  statusObservable: controller.dnsPingStatus,
                  showLatency: true,
                ),
                SizedBox(height: AppTheme.spacingDefault),
                // 中心服务Ping
                _buildCheckItem(
                  label: l10n.centerServerPingResult,
                  statusObservable: controller.centerServerPingStatus,
                  showLatency: true,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppTheme.spacingXL),
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
              ),
              elevation: 0,
            ),
            onPressed: controller.checkAll,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, size: 22.sp),
                SizedBox(width: AppTheme.spacingM),
                Text(
                  l10n.refreshCheck,
                  style: AppTheme.textTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem({
    required String label,
    required Rx<NetworkCheckResult> statusObservable,
    bool showLatency = false,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.textSubtitle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Obx(() {
            final result = statusObservable.value;
            return _buildStatusIndicator(result);
          }),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(NetworkCheckResult result) {
    switch (result.status) {
      case NetworkCheckStatus.pending:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_rounded, size: 20.sp, color: AppTheme.textTertiary),
            SizedBox(width: AppTheme.spacingS),
            Text(
              controller.getStatusText(result),
              style: AppTheme.textSubtitle.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        );

      case NetworkCheckStatus.checking:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18.w,
              height: 18.h,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.warningColor,
                ),
              ),
            ),
            SizedBox(width: AppTheme.spacingS),
            Text(
              controller.getStatusText(result),
              style: AppTheme.textSubtitle.copyWith(color: AppTheme.warningColor),
            ),
          ],
        );

      case NetworkCheckStatus.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 20.sp, color: AppTheme.successColor),
            SizedBox(width: AppTheme.spacingS),
            Text(
              controller.getStatusText(result),
              style: AppTheme.textSubtitle.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );

      case NetworkCheckStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel_rounded, size: 20.sp, color: AppTheme.errorColor),
            SizedBox(width: AppTheme.spacingS),
            Flexible(
              child: Text(
                controller.getStatusText(result),
                style: AppTheme.textSubtitle.copyWith(color: AppTheme.errorColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
    }
  }
}
