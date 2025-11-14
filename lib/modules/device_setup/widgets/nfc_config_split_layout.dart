import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// NFC配置左右分栏布局组件
class NfcConfigSplitLayout extends StatelessWidget {
  final Widget leftSection; // 左侧配置区域
  final Widget rightSection; // 右侧数据显示区域

  const NfcConfigSplitLayout({
    super.key,
    required this.leftSection,
    required this.rightSection,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧配置区域 (50%)
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGrey,
              border: Border(
                right: BorderSide(color: AppTheme.borderColor, width: 1.w),
              ),
            ),
            child: leftSection,
          ),
        ),

        // 右侧数据显示区域 (50%)
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(AppTheme.spacingXL),
            color: Colors.white,
            child: rightSection,
          ),
        ),
      ],
    );
  }
}
