import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/services/sunmi_printer_service.dart';
import '../../../data/services/external_printer_service.dart';
import '../../../app/theme/app_theme.dart';

/// 可拖动的日志面板
/// 整合内置和外接打印机的调试日志
class DraggableLogPanel extends StatefulWidget {
  const DraggableLogPanel({super.key});

  @override
  State<DraggableLogPanel> createState() => _DraggableLogPanelState();
}

class _DraggableLogPanelState extends State<DraggableLogPanel> {
  double _rightPosition = -380.0; // 初始隐藏（在屏幕右侧外）
  bool _isDragging = false;
  bool _isExpanded = false; // 是否展开

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: _rightPosition,
      top: 80.h,
      bottom: 100.h,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _isDragging = true;
            // 向右拖动时，rightPosition减小（更靠右）
            // 向左拖动时，rightPosition增大（更靠左）
            _rightPosition -= details.delta.dx;
            // 限制拖动范围：完全隐藏(-380)到完全展开(0)
            _rightPosition = _rightPosition.clamp(-380.0, 0.0);
            // 更新展开状态
            _isExpanded = _rightPosition > -190.0; // 拖动超过一半算展开
          });
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: Container(
          width: 380.w, // 缩小宽度，避免覆盖主内容
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // 终端深色主题，保持不变
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.borderRadiusLarge),
              bottomLeft: Radius.circular(AppTheme.borderRadiusLarge),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // 标题栏（可拖动）
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingDefault,
                  vertical: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D), // 终端主题色
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                  ),
                ),
                child: Row(
                  children: [
                    // 拖动手柄
                    Icon(
                      Icons.drag_indicator,
                      size: 20.sp,
                      color: _isDragging
                          ? const Color(0xFF4EC9B0)
                          : AppTheme.textSecondary,
                    ),
                    SizedBox(width: AppTheme.spacingS),
                    Icon(
                      Icons.terminal,
                      size: 18.sp,
                      color: const Color(0xFF4EC9B0), // 终端绿色主题
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
                    // 展开/收起按钮
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                          _rightPosition = _isExpanded ? 0 : -380.0;
                        });
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
                        child: Icon(
                          _isExpanded
                              ? Icons.chevron_right
                              : Icons.chevron_left,
                          size: 18.sp,
                          color: const Color(0xFFCCCCCC),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingS),
                    // 清空按钮
                    InkWell(
                      onTap: () {
                        try {
                          Get.find<SunmiPrinterService>().debugLogs.clear();
                        } catch (e) {}
                        try {
                          Get.find<ExternalPrinterService>().debugLogs.clear();
                        } catch (e) {}
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
              Expanded(child: _buildLogContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogContent() {
    return Obx(() {
      final allLogs = <String>[];

      // 获取内置打印机日志
      try {
        final sunmiService = Get.find<SunmiPrinterService>();
        allLogs.addAll(sunmiService.debugLogs.map((log) => '[内置] $log'));
      } catch (e) {}

      // 获取外接打印机日志
      try {
        final externalService = Get.find<ExternalPrinterService>();
        allLogs.addAll(externalService.debugLogs.map((log) => '[外接] $log'));
      } catch (e) {}

      // 按时间排序（假设日志格式包含时间戳）
      allLogs.sort((a, b) {
        try {
          final timeA = a.substring(a.indexOf('[') + 1, a.indexOf(']'));
          final timeB = b.substring(b.indexOf('[') + 1, b.indexOf(']'));
          return timeB.compareTo(timeA); // 最新的在前面
        } catch (e) {
          return 0;
        }
      });

      if (allLogs.isEmpty) {
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
                '暂无日志',
                style: AppTheme.textBody.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: AppTheme.spacingS),
              Text(
                '点击"测试打印"或"扫描"查看日志',
                textAlign: TextAlign.center,
                style: AppTheme.textCaption.copyWith(
                  color: const Color(0xFF555555),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(AppTheme.spacingM),
        itemCount: allLogs.length,
        itemBuilder: (context, index) {
          final log = allLogs[index];
          final isError =
              log.contains('✗') || log.contains('错误') || log.contains('失败');
          final isSuccess = log.contains('✓') || log.contains('成功');
          final isSeparator = log.contains('=====');
          final isExternal = log.startsWith('[外接]');

          Color textColor = const Color(0xFFCCCCCC);
          if (isError) {
            textColor = const Color(0xFFF48771); // 终端错误红色
          } else if (isSuccess) {
            textColor = isExternal
                ? const Color(0xFF9C27B0)
                : const Color(0xFF4EC9B0); // 终端成功绿色
          } else if (isSeparator) {
            textColor = const Color(0xFF569CD6); // 终端蓝色
          }

          return Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spacingXS),
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
    });
  }
}
