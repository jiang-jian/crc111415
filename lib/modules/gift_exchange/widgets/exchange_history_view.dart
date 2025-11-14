import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/table/index.dart';
import '../../../core/widgets/tabs.dart';
import '../controllers/exchange_record_controller.dart';

/// ExchangeHistoryView
/// 兑换记录视图 - 完全替换左侧区域
class ExchangeHistoryView extends StatefulWidget {
  const ExchangeHistoryView({super.key});

  @override
  State<ExchangeHistoryView> createState() => _ExchangeHistoryViewState();
}

class _ExchangeHistoryViewState extends State<ExchangeHistoryView> {
  late final ExchangeRecordController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ExchangeRecordController());
  }

  @override
  void dispose() {
    Get.delete<ExchangeRecordController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 12.h),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                child: Tabs(
                  tabs: const ['彩票兑换', '游戏币兑换'],
                  onTap: (index) {
                    controller.selectPaymentType(
                      index == 0 ? PaymentType.lottery : PaymentType.gameCoin,
                    );
                  },
                  children: [
                    _buildExchangeTable(PaymentType.lottery),
                    _buildExchangeTable(PaymentType.gameCoin),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingDefault),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: .08),
            AppTheme.primaryColor.withValues(alpha: .03),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: .1),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: .8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: .3),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Icon(
              Icons.history_rounded,
              size: 26.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '兑换记录',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: .5,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '查看历史兑换订单',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                  letterSpacing: .2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeTable(PaymentType type) {
    return DataTableWidget(
      config: TableConfig(
        apiUrl: '/api/gift/exchange/records',
        searchFields: [
          SearchFieldConfig(
            key: 'phoneNumber',
            label: '会员手机号',
            type: SearchFieldType.input,
            placeholder: '请输入会员手机号',
          ),
          SearchFieldConfig(
            key: 'dateRange',
            label: '日期范围',
            type: SearchFieldType.dateRange,
          ),
          SearchFieldConfig(
            key: 'orderNumber',
            label: '订单编号',
            type: SearchFieldType.input,
            placeholder: '请输入订单编号',
          ),
        ],
        apiParams: {
          'paymentType': type == PaymentType.lottery ? 'lottery' : 'gameCoin',
        },
      ),
      columns: [
        ColumnConfig(
          key: 'time',
          title: '时间',
          width: 140,
          render: (value, row) {
            return Text(
              value?.toString() ?? '-',
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
            );
          },
        ),
        ColumnConfig(key: 'orderNumber', title: '订单编号', width: 180),
        ColumnConfig(key: 'memberLevel', title: '会员等级', width: 100),
        ColumnConfig(
          key: 'orderStatus',
          title: '订单状态',
          width: 90,
          render: (value, row) => _buildStatusBadge(value?.toString() ?? ''),
        ),
        ColumnConfig(key: 'memberPhone', title: '会员手机号', width: 120),
        ColumnConfig(key: 'paymentMethod', title: '支付方式', width: 90),
        ColumnConfig(
          key: 'amount',
          title: '支付金额',
          width: 130,
          render: (value, row) {
            return Text(
              'AED ${value?.toString() ?? '0.00'}',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.priceColor,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        ColumnConfig(key: 'cashier', title: '收银员', width: 100),
        ColumnConfig(
          key: 'remark',
          title: '备注',
          render: (value, row) {
            return Text(
              value?.toString() ?? '-',
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case '已完成':
        color = AppTheme.successColor;
        break;
      case '待处理':
        color = AppTheme.warningColor;
        break;
      case '已取消':
        color = AppTheme.errorColor;
        break;
      default:
        color = Colors.grey;
    }

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: 12.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
