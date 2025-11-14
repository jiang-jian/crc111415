/// CardScanDialog
/// 通用刷卡对话框组件
/// 可配置标题、提示文本、超时时间等
/// 作者：AI 自动生成
/// 更新时间：2025-11-11

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/theme/app_theme.dart';
import 'dialog.dart';

class CardScanDialog {
  /// 显示刷卡对话框
  /// [title] 对话框标题
  /// [hint] 提示文本
  /// [onCardScanned] 刷卡成功回调，返回卡号
  /// [timeout] 超时时间（秒），null 表示无限等待
  static Future<String?> show({
    required BuildContext context,
    String title = '会员登录',
    String hint = '请刷会员卡',
    String subHint = '请将会员卡靠近读卡器',
    Future<String?> Function()? onCardScanned,
    int? timeout,
    VoidCallback? onRegister,
  }) async {
    final completer = Completer<String?>();

    AppDialog.custom(
      title: title,
      content: _CardScanContent(hint: hint, subHint: subHint),
      confirmText: '注册会员',
      cancelText: '取消',
      width: 500.w,
      barrierDismissible: false,
      onConfirm: () {
        AppDialog.hide(false);
        if (onRegister != null) {
          onRegister();
        }
      },
      onCancel: () {
        completer.complete(null);
      },
    );

    // 模拟刷卡
    if (onCardScanned != null) {
      final cardNumber = await onCardScanned();
      if (!completer.isCompleted) {
        AppDialog.hide();
        completer.complete(cardNumber);
      }
    }

    return completer.future;
  }
}

class _CardScanContent extends StatelessWidget {
  final String hint;
  final String subHint;

  const _CardScanContent({required this.hint, required this.subHint});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.credit_card, size: 64.sp, color: AppTheme.primaryColor),
        SizedBox(height: 24.h),
        Text(
          hint,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          subHint,
          style: TextStyle(fontSize: 16.sp, color: AppTheme.textSecondary),
        ),
        SizedBox(height: 32.h),
        Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: .3),
              width: 2.w,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            color: AppTheme.primaryColor.withValues(alpha: .05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.nfc,
                size: 48.sp,
                color: AppTheme.primaryColor.withValues(alpha: .6),
              ),
              SizedBox(height: 8.h),
              Text(
                '等待刷卡...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
