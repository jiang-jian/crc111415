import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/widgets/toast.dart';
import '../../app/theme/app_theme.dart';

class ChangePasswordForm extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final bool showButtons;

  const ChangePasswordForm({
    super.key,
    this.onSuccess,
    this.onCancel,
    this.showButtons = true,
  });

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入旧密码';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入新密码';
    }
    if (value.length < 6) {
      return '密码长度至少6位';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请再次输入新密码';
    }
    if (value != _newPasswordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: 调用修改密码 API
      // await AuthService().changePassword(
      //   oldPassword: _oldPasswordController.text,
      //   newPassword: _newPasswordController.text,
      // );

      // 模拟 API 调用
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Toast.success(message: '密码修改成功');
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      Toast.error(message: '密码修改失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).pop(false);
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: AppTheme.textBody.copyWith(color: Colors.black54),
      hintStyle: AppTheme.textBody.copyWith(color: Colors.black38),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        borderSide: BorderSide(color: AppTheme.errorColor, width: 2.w),
      ),
      errorStyle: AppTheme.textCaption.copyWith(color: AppTheme.errorColor),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.error)) {
          return AppTheme.textBody.copyWith(color: AppTheme.errorColor);
        }
        return AppTheme.textBody.copyWith(color: AppTheme.primaryColor);
      }),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingDefault,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppTheme.spacingDefault),
          TextFormField(
            controller: _oldPasswordController,
            obscureText: _obscureOldPassword,
            validator: _validateOldPassword,
            style: AppTheme.textSubtitle.copyWith(color: Colors.black87),
            decoration: _buildInputDecoration(
              labelText: '旧密码',
              hintText: '请输入旧密码',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                  size: 18.sp,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() => _obscureOldPassword = !_obscureOldPassword);
                },
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacingDefault),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            validator: _validateNewPassword,
            style: AppTheme.textSubtitle.copyWith(color: Colors.black87),
            decoration: _buildInputDecoration(
              labelText: '新密码',
              hintText: '请输入新密码',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  size: 18.sp,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacingDefault),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            style: AppTheme.textSubtitle.copyWith(color: Colors.black87),
            decoration: _buildInputDecoration(
              labelText: '确认新密码',
              hintText: '请再次输入新密码',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 18.sp,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
            ),
          ),
          if (widget.showButtons) ...[
            SizedBox(height: AppTheme.spacingL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleCancel,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: AppTheme.spacingDefault.h,
                      ),
                      side: BorderSide(color: AppTheme.borderColor, width: 1.w),
                      foregroundColor: AppTheme.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusDefault,
                        ),
                      ),
                    ),
                    child: Text('取消', style: AppTheme.textSubtitle),
                  ),
                ),
                SizedBox(width: AppTheme.spacingDefault),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: AppTheme.spacingDefault.h,
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusDefault,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            '确定',
                            style: AppTheme.textSubtitle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
