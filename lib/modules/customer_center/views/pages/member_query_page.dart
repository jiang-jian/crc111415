import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/card_scan_dialog.dart';
import '../../../../core/widgets/table/index.dart';
import '../../../../core/widgets/tabs.dart';
import '../../controllers/member_query_controller.dart';
import '../../widgets/member_action_dialogs.dart';

class MemberQueryPage extends StatefulWidget {
  const MemberQueryPage({super.key});

  @override
  State<MemberQueryPage> createState() => _MemberQueryPageState();
}

class _MemberQueryPageState extends State<MemberQueryPage> {
  late final MemberQueryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MemberQueryController(), tag: 'member_query');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCardScanDialog();
    });
  }

  @override
  void dispose() {
    Get.delete<MemberQueryController>(tag: 'member_query');
    super.dispose();
  }

  Future<void> _showCardScanDialog() async {
    await CardScanDialog.show(
      context: context,
      onCardScanned: () async {
        await controller.simulateCardScan();
        return controller.memberInfo.value?.cardNumber;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLoggedIn.value) {
        return _buildEmptyState();
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final minTableHeight = 700.h;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppTheme.spacingM),
                    child: _buildMemberCard(),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: SizedBox(
                      height: minTableHeight,
                      child: _buildDataTables(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(48.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingXL),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card_outlined,
                size: 80.sp,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              '请刷会员卡',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: .5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '将会员卡靠近读卡器',
              style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: _showCardScanDialog,

              child: Text(
                '重新刷卡',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard() {
    final member = controller.memberInfo.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '会员卡信息',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: .3,
              ),
            ),
            const Spacer(),
            _buildActionButton('挂失', Icons.report_problem_outlined, () async {
              final confirmed =
                  await MemberActionDialogs.showLossReportConfirmDialog(
                    context,
                  );
              if (confirmed) {
                controller.handleLossReport();
              }
            }),
            SizedBox(width: 10.w),
            _buildActionButton(
              '修改卡密',
              Icons.lock_outline,
              () => MemberActionDialogs.showChangePasswordDialog(
                context,
                controller,
              ),
            ),
            SizedBox(width: 10.w),
            _buildActionButton(
              '资产分配',
              Icons.account_balance_wallet_outlined,
              () => MemberActionDialogs.showAssetAllocationDialog(
                context,
                controller,
              ),
            ),
            SizedBox(width: AppTheme.spacingDefault),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed =
                    await MemberActionDialogs.showLogoutConfirmDialog(context);
                if (confirmed) {
                  controller.logout();
                }
              },
              icon: Icon(Icons.logout, size: 16.sp),
              label: Text('退出登录', style: TextStyle(fontSize: 14.sp)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: BorderSide(
                  color: AppTheme.errorColor.withValues(alpha: .3),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _buildCardInput(member)),
              SizedBox(width: 20.w),
              Expanded(flex: 3, child: _buildCardAssets(member)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
    );
  }

  Widget _buildCardInput(member) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.backgroundGrey, AppTheme.backgroundGrey],
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: Colors.black.withValues(alpha: .03),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: member.isMainCard
                      ? AppTheme.primaryColor
                      : AppTheme.warningColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (member.isMainCard
                                  ? AppTheme.primaryColor
                                  : AppTheme.warningColor)
                              .withValues(alpha: .2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  member.isMainCard ? '主卡' : '副卡',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .3,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingS),
              if (member.isLost)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.errorColor.withValues(alpha: .2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '已挂失',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .3,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow('卡片ID：', member.cardNumber),
          _buildInfoRow('手机号：', member.phoneNumber),
          _buildInfoRow(
            '邮箱：',
            member.email ?? '未绑定',
            actionText: member.email == null ? '绑定邮箱' : null,
            onActionTap: member.email == null
                ? () => MemberActionDialogs.showBindEmailDialog(
                    context,
                    controller,
                  )
                : null,
          ),
          _buildInfoRow(
            '手表 ID：',
            member.watchId ?? '未绑定',
            actionText: member.watchId == null ? '绑定' : null,
            onActionTap: member.watchId == null
                ? () => MemberActionDialogs.showBindWatchDialog(
                    context,
                    controller,
                  )
                : null,
          ),
          const Spacer(),
          Divider(height: 32.h, color: Colors.black.withValues(alpha: .06)),
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                size: 14.sp,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                '创建时间',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: value.contains('未绑定')
                    ? Colors.grey.shade400
                    : AppTheme.textPrimary,
              ),
            ),
          ),
          if (actionText != null && onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionText,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardAssets(member) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final lastPlayDate = member.expiryDate ?? DateTime.now();

    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.backgroundGrey, AppTheme.backgroundGrey],
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: Colors.black.withValues(alpha: .03),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingS),
              Text(
                '当前卡资产',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  letterSpacing: .3,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              _buildAssetItem(
                '游戏币',
                member.assets.gameCoins.toInt(),
                '最后一次游玩: ${dateFormat.format(lastPlayDate)}',
                Icons.videogame_asset_outlined,
              ),
              SizedBox(width: AppTheme.spacingM),
              _buildAssetItem(
                '超级币',
                member.assets.superCoins.toInt(),
                '',
                Icons.stars_outlined,
              ),
              SizedBox(width: AppTheme.spacingM),
              _buildAssetItem(
                '彩票',
                member.assets.lottery.toInt(),
                '(共享)',
                Icons.confirmation_number_outlined,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildAssetItem('优惠券', 0, '', Icons.local_offer_outlined),
              SizedBox(width: AppTheme.spacingM),
              _buildAssetItem(
                '门票',
                member.assets.doors.toInt(),
                '',
                Icons.local_activity_outlined,
              ),
              SizedBox(width: AppTheme.spacingM),
              _buildAssetItem(
                '盲盒',
                member.assets.mysteryBoxes.toInt(),
                '',
                Icons.card_giftcard_outlined,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildAssetItem('道具', 0, '', Icons.category_outlined),
              SizedBox(width: AppTheme.spacingM),
              _buildAssetItem(
                '数字人',
                member.assets.memberCount,
                '',
                Icons.person_outline,
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetItem(
    String label,
    int value,
    String suffix,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: Colors.black.withValues(alpha: .04),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                  ),
                  child: Icon(icon, size: 16.sp, color: AppTheme.primaryColor),
                ),
                SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1,
                  ),
                ),
                if (suffix.isNotEmpty) ...[
                  SizedBox(width: AppTheme.spacingXS),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Text(
                      suffix,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTables() {
    return Tabs(
      tabs: const ['卡管理', '游玩明细', '彩票明细', '兑换明细', '道具明细', '数字人明细', '状态'],
      children: [
        _buildCardManagementTable(),
        _buildGamePlayTable(),
        _buildLotteryTable(),
        _buildExchangeTable(),
        _buildPropsTable(),
        _buildDigitalTable(),
        _buildStatusTable(),
      ],
    );
  }

  Widget _buildCardManagementTable() {
    return DataTableWidget(
      config: TableConfig(
        apiUrl: '/midst-auth/auth/role/find/all',
        searchFields: [
          SearchFieldConfig(
            key: 'cardNumber',
            label: '卡号',
            type: SearchFieldType.input,
            placeholder: '请输入卡号',
          ),
          SearchFieldConfig(
            key: 'dateRange',
            label: '取卡时间',
            type: SearchFieldType.date,
          ),
        ],
      ),
      columns: [
        ColumnConfig(key: 'cardNumber', title: '卡号', fixed: 'left'),
        ColumnConfig(key: 'store', title: '领卡门店'),
        ColumnConfig(key: 'takeTime', title: '取卡时间'),
        ColumnConfig(key: 'operator', title: '操作地址'),
        ColumnConfig(key: 'cardType', title: '卡片类型'),
        ColumnConfig(key: 'gameCoins', title: '游戏币'),
        ColumnConfig(key: 'superCoins', title: '超级币'),
        ColumnConfig(key: 'lottery', title: '彩票'),
        ColumnConfig(key: 'coupons', title: '优惠券'),
        ColumnConfig(key: 'doors', title: '门票'),
        ColumnConfig(key: 'mysteryBox', title: '盲盒'),
        ColumnConfig(key: 'props', title: '道具'),
        ColumnConfig(key: 'members', title: '数字人'),
        ColumnConfig(key: 'status', title: '状态'),
        ColumnConfig(
          key: 'actions',
          width: 140,
          title: '操作',
          render: (value, row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: () {},
                    child: Text('解绑', style: TextStyle(fontSize: 12.sp)),
                  ),
                ),
                SizedBox(width: AppTheme.spacingXS),
                Flexible(
                  child: TextButton(
                    onPressed: () {},
                    child: Text('查看', style: TextStyle(fontSize: 12.sp)),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGamePlayTable() {
    return DataTableWidget(
      config: TableConfig(
        apiUrl: '/api/member/game-play',
        searchFields: [
          SearchFieldConfig(
            key: 'phone',
            label: '会员手机号',
            type: SearchFieldType.input,
          ),
          SearchFieldConfig(
            key: 'dateRange',
            label: '时间范围',
            type: SearchFieldType.dateRange,
          ),
        ],
      ),
      columns: [
        ColumnConfig(key: 'time', title: '时间'),
        ColumnConfig(key: 'orderNo', title: '订单编号'),
        ColumnConfig(key: 'level', title: '会员等级'),
        ColumnConfig(key: 'status', title: '订单状态'),
        ColumnConfig(key: 'phone', title: '会员手机号'),
        ColumnConfig(key: 'payMethod', title: '支付方式'),
        ColumnConfig(key: 'amount', title: '支付金额'),
        ColumnConfig(key: 'cashier', title: '收银员'),
        ColumnConfig(key: 'remark', title: '备注'),
      ],
    );
  }

  Widget _buildLotteryTable() {
    return DataTableWidget(
      config: TableConfig(
        apiUrl: '/api/member/lottery',
        searchFields: [
          SearchFieldConfig(
            key: 'dateRange',
            label: '时间范围',
            type: SearchFieldType.dateRange,
          ),
        ],
      ),
      columns: [
        ColumnConfig(key: 'time', title: '时间'),
        ColumnConfig(key: 'type', title: '类型'),
        ColumnConfig(key: 'amount', title: '数量'),
        ColumnConfig(key: 'balance', title: '余额'),
        ColumnConfig(key: 'remark', title: '备注'),
      ],
    );
  }

  Widget _buildExchangeTable() {
    return DataTableWidget(
      config: TableConfig(
        apiUrl: '/api/member/exchange',
        searchFields: [
          SearchFieldConfig(
            key: 'dateRange',
            label: '时间范围',
            type: SearchFieldType.dateRange,
          ),
        ],
      ),
      columns: [
        ColumnConfig(key: 'time', title: '时间'),
        ColumnConfig(key: 'orderNo', title: '订单编号'),
        ColumnConfig(key: 'productName', title: '商品名称'),
        ColumnConfig(key: 'quantity', title: '数量'),
        ColumnConfig(key: 'price', title: '单价'),
        ColumnConfig(key: 'total', title: '总价'),
      ],
    );
  }

  Widget _buildPropsTable() {
    return DataTableWidget(
      config: TableConfig(
        apiUrl: '/api/member/props',
        searchFields: [
          SearchFieldConfig(
            key: 'dateRange',
            label: '时间范围',
            type: SearchFieldType.dateRange,
          ),
        ],
      ),
      columns: [
        ColumnConfig(key: 'time', title: '时间'),
        ColumnConfig(key: 'propName', title: '道具名称'),
        ColumnConfig(key: 'quantity', title: '数量'),
        ColumnConfig(key: 'status', title: '状态'),
      ],
    );
  }

  Widget _buildDigitalTable() {
    return DataTableWidget(
      config: TableConfig(
        apiUrl: '/api/member/digital',
        searchFields: [
          SearchFieldConfig(
            key: 'dateRange',
            label: '时间范围',
            type: SearchFieldType.dateRange,
          ),
        ],
      ),
      columns: [
        ColumnConfig(key: 'time', title: '时间', width: 140),
        ColumnConfig(key: 'digitalId', title: '数字人ID', width: 150),
        ColumnConfig(key: 'name', title: '名称', width: 150),
        ColumnConfig(key: 'level', title: '等级', width: 100),
      ],
    );
  }

  Widget _buildStatusTable() {
    return DataTableWidget(
      config: TableConfig(
        apiUrl: '/api/member/status',
        searchFields: [
          SearchFieldConfig(
            key: 'dateRange',
            label: '时间范围',
            type: SearchFieldType.dateRange,
          ),
        ],
      ),
      columns: [
        ColumnConfig(key: 'time', title: '时间'),
        ColumnConfig(key: 'status', title: '状态'),
        ColumnConfig(key: 'operator', title: '操作人'),
        ColumnConfig(key: 'remark', title: '备注'),
      ],
    );
  }
}
