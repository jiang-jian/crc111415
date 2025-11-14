import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';

/// 读卡失败弹窗
class CardReadingFailureDialog extends StatelessWidget {
  final String? errorMessage; // 失败原因描述
  final VoidCallback? onRetry; // 重新登记回调
  final VoidCallback? onCancel; // 取消回调

  const CardReadingFailureDialog({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420.w,
        padding: EdgeInsets.all(AppTheme.spacingXL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderColor, width: 1.h),
                ),
              ),
              child: Text(
                '读卡登记',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 32.h),

            // 错误图标 - 红色圆圈带 X
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 48.sp,
                color: const Color(0xFFE53935),
              ),
            ),

            SizedBox(height: 24.h),

            // 失败标题
            Text(
              '读卡登记失败',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // 失败原因描述
            Text(
              errorMessage ?? '此处是失败原因描述',
              style: TextStyle(
                fontSize: 15.sp,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            // 按钮区域
            Row(
              children: [
                // 取消按钮 - 白色边框
                Expanded(child: _buildCancelButton(context)),

                SizedBox(width: AppTheme.spacingDefault),

                // 重新登记按钮 - 紫色系
                Expanded(child: _buildRetryButton(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 取消按钮 - 白色边框
  Widget _buildCancelButton(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          child: Center(
            child: Text(
              '取消',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 重新登记按钮 - 紫色系
  Widget _buildRetryButton(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9C27B0), // 紫色
            Color(0xFF7B1FA2), // 深紫色
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            onRetry?.call();
          },
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          child: Center(
            child: Text(
              '重新登记',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 显示读卡失败弹窗
void showCardReadingFailureDialog(
  BuildContext context, {
  String? errorMessage,
  VoidCallback? onRetry,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // 不允许点击外部关闭
    barrierColor: Colors.black.withValues(alpha: 0.5), // 半透明遮罩
    builder: (context) => CardReadingFailureDialog(
      errorMessage: errorMessage,
      onRetry: onRetry,
      onCancel: onCancel,
    ),
  );
}
