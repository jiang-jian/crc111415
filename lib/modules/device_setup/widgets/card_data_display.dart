import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// 卡片数据显示组件
class CardDataDisplay extends StatelessWidget {
  final Map<String, dynamic> cardData;

  const CardDataDisplay({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppTheme.spacingL),
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Text('读取数据', style: AppTheme.textTitle),
            ],
          ),

          SizedBox(height: AppTheme.spacingDefault),

          // 数据列表
          _buildDataRow('卡片 UID', cardData['uid'] ?? '未知'),
          SizedBox(height: AppTheme.spacingM),
          _buildDataRow('卡片类型', cardData['type'] ?? '未知'),
          if (cardData['capacity'] != null) ...[
            SizedBox(height: AppTheme.spacingM),
            _buildDataRow('卡片容量', cardData['capacity'] ?? '未知'),
          ],
          SizedBox(height: AppTheme.spacingM),
          _buildDataRow('读取时间', _formatTimestamp(cardData['timestamp'])),

          // 成功标识
          if (cardData['isValid'] == true) ...[
            SizedBox(height: AppTheme.spacingDefault),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingDefault,
                vertical: AppTheme.spacingS,
              ),
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
                    size: 18.sp,
                    color: AppTheme.successColor,
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    '卡片验证通过',
                    style: AppTheme.textBody.copyWith(
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
    );
  }

  /// 构建数据行
  Widget _buildDataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: AppTheme.textBody.copyWith(
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingDefault),
        Expanded(
          child: Text(
            value,
            style: AppTheme.textBody.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  /// 格式化时间戳
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
