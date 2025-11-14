import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/services/external_printer_service.dart';
import '../../../app/theme/app_theme.dart';

/// 外接打印机调试日志面板
/// 用于显示USB打印机的操作日志
class ExternalPrinterLogPanel extends StatelessWidget {
  const ExternalPrinterLogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.find<ExternalPrinterService>();

    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.textPrimary),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, size: 18.sp, color: const Color(0xFF9C27B0)),
                SizedBox(width: AppTheme.spacingS),
                Text(
                  '外接设备日志',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    service.clearDebugLogs();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E3E3E),
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
                          style: TextStyle(
                            fontSize: 12.sp,
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
              final logs = service.debugLogs;

              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 32.sp,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '暂无日志\n点击"扫描"或"测试打印"查看操作日志',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
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
                  final isError =
                      log.contains('✗') ||
                      log.contains('错误') ||
                      log.contains('失败');
                  final isSuccess = log.contains('✓') || log.contains('成功');
                  final isSeparator = log.contains('=====');

                  Color textColor = const Color(0xFFCCCCCC);
                  if (isError) {
                    textColor = const Color(0xFFF48771);
                  } else if (isSuccess) {
                    textColor = const Color(0xFF9C27B0);
                  } else if (isSeparator) {
                    textColor = const Color(0xFF569CD6);
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontSize: 11.sp,
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
