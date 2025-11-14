import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// NFC配置右侧数据显示区域组件
class NfcRightDataSection extends StatelessWidget {
  final Map<String, dynamic>? cardData;
  final String cardReadStatus;

  const NfcRightDataSection({
    super.key,
    this.cardData,
    required this.cardReadStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Container(
              width: 4.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ),
            SizedBox(width: AppTheme.spacingM),
            Text('卡片数据', style: AppTheme.textLarge),
          ],
        ),

        SizedBox(height: AppTheme.spacingXL),

        // 数据显示区域
        Expanded(child: _buildDataContent()),
      ],
    );
  }

  Widget _buildDataContent() {
    if (cardData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80.sp,
              color: AppTheme.backgroundDisabled,
            ),
            SizedBox(height: AppTheme.spacingL),
            Text(
              '暂无数据',
              style: AppTheme.textTitle.copyWith(color: AppTheme.textTertiary),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              '请将卡片靠近读卡器',
              style: AppTheme.textBody.copyWith(color: AppTheme.textDisabled),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingXL),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGrey,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
          border: Border.all(
            color: AppTheme.successColor.withValues(alpha: 0.3),
            width: 2.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 成功图标
            if (cardData!['isValid'] == true)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingDefault,
                  vertical: AppTheme.spacingS,
                ),
                margin: EdgeInsets.only(bottom: AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusDefault,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20.sp,
                      color: AppTheme.successColor,
                    ),
                    SizedBox(width: AppTheme.spacingS),
                    Text(
                      '卡片验证通过',
                      style: AppTheme.textSubtitle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),

            // 数据列表
            _buildDataRow('卡片 UID', cardData!['uid'] ?? '未知'),
            SizedBox(height: 20.h),
            _buildDataRow('卡片类型', cardData!['type'] ?? '未知'),
            if (cardData!['capacity'] != null) ...[
              SizedBox(height: 20.h),
              _buildDataRow('卡片容量', cardData!['capacity'] ?? '未知'),
            ],
            SizedBox(height: 20.h),
            _buildDataRow('读取时间', _formatTimestamp(cardData!['timestamp'])),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.textBody.copyWith(
            color: AppTheme.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppTheme.spacingS),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingDefault,
            vertical: AppTheme.spacingM,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          ),
          child: Text(
            value,
            style: AppTheme.textSubtitle.copyWith(
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
}
