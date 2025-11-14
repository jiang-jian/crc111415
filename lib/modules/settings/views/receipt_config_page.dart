import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/receipt_editor_config.dart';
import 'receipt_settings_view.dart';

/// 统一的小票配置页面（包含3个Tab）
class ReceiptConfigPage extends StatefulWidget {
  const ReceiptConfigPage({super.key});

  @override
  State<ReceiptConfigPage> createState() => _ReceiptConfigPageState();
}

class _ReceiptConfigPageState extends State<ReceiptConfigPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          // 顶部标题栏和Tab栏
          Container(
            padding: EdgeInsets.fromLTRB(
              AppTheme.spacingXL,
              AppTheme.spacingXL,
              AppTheme.spacingXL,
              0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor,
                  width: 1.w,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                Text(
                  '小票配置',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '配置热敏打印机小票打印模板',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.textTertiary,
                  ),
                ),
                SizedBox(height: AppTheme.spacingL),
                // Tab栏
                TabBar(
                  controller: _tabController,
                  labelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: const [
                    Tab(text: '托管小票'),
                    Tab(text: '支付小票'),
                    Tab(text: '礼品小票'),
                  ],
                ),
              ],
            ),
          ),
          // Tab内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ReceiptSettingsView(
                  config: ReceiptEditorConfig.custody,
                ),
                ReceiptSettingsView(
                  config: ReceiptEditorConfig.payment,
                ),
                ReceiptSettingsView(
                  config: ReceiptEditorConfig.exchange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
