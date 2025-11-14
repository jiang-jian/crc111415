import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/services/sunmi_printer_service.dart';
import '../../../app/theme/app_theme.dart';

/// 打印机调试日志面板组件
class PrinterDebugLogPanel extends StatelessWidget {
  const PrinterDebugLogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final printerService = Get.find<SunmiPrinterService>();

    return Container(
      height: 420.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // 终端深色主题
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.textPrimary), // 终端边框色
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingDefault,
              vertical: AppTheme.spacingM,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D), // 终端主题色
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                topRight: Radius.circular(AppTheme.borderRadiusLarge),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.terminal,
                  size: 18.sp,
                  color: const Color(0xFF4EC9B0), // 终端绿色
                ),
                SizedBox(width: AppTheme.spacingS),
                Text(
                  'SDK调试日志',
                  style: AppTheme.textBody.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    printerService.debugLogs.clear();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E3E3E), // 终端按钮背景
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear_all,
                          size: 14.sp,
                          color: const Color(0xFFCCCCCC),
                        ),
                        SizedBox(width: AppTheme.spacingXS),
                        Text(
                          '清空',
                          style: AppTheme.textCaption.copyWith(
                            color: const Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 日志内容
          Expanded(
            child: Obx(() {
              final logs = printerService.debugLogs;

              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48.sp,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: AppTheme.spacingM),
                      Text(
                        '暂无日志\n点击"重新检测"或"测试打印"查看SDK调用日志',
                        textAlign: TextAlign.center,
                        style: AppTheme.textBody.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(AppTheme.spacingM),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final isError = log.contains('✗') || log.contains('错误');
                  final isSuccess = log.contains('✓');
                  final isSeparator = log.contains('=====');

                  Color textColor = const Color(0xFFCCCCCC);
                  if (isError) {
                    textColor = const Color(0xFFF48771); // 终端错误红色
                  } else if (isSuccess) {
                    textColor = const Color(0xFF4EC9B0); // 终端成功绿色
                  } else if (isSeparator) {
                    textColor = const Color(0xFF569CD6); // 终端蓝色
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.spacingXS),
                    child: Text(
                      log,
                      style: AppTheme.textCaption.copyWith(
                        fontFamily: 'monospace',
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
