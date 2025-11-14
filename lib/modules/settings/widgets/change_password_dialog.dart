/// ChangePasswordDialog
/// 修改密码对话框

import 'package:ailand_pos/core/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/dialog.dart';

class ChangePasswordDialog {
  static Future<void> show(
    BuildContext context, {
    required String cardNumber,
    required String currentPassword,
    required Function(String newPassword) onPasswordChanged,
  }) async {
    final canConfirm = ValueNotifier<bool>(false);
    final formKey = GlobalKey<_ChangePasswordFormState>();

    await AppDialog.custom(
      title: '修改密码',
      content: _ChangePasswordForm(
        key: formKey,
        cardNumber: cardNumber,
        currentPassword: currentPassword,
        canConfirmNotifier: canConfirm,
        onPasswordChanged: onPasswordChanged,
        onSubmitSuccess: () {
          // 验证成功后手动关闭对话框
          AppDialog.hide(true);
        },
      ),
      confirmText: '确定',
      width: 500.w,
      barrierDismissible: false,
      canConfirmNotifier: canConfirm,
      autoCloseOnConfirm: false, // 不自动关闭，手动控制
      onConfirm: () {
        // 触发表单验证
        formKey.currentState?.submitForm();
      },
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  final String cardNumber;
  final String currentPassword;
  final ValueNotifier<bool> canConfirmNotifier;
  final Function(String newPassword) onPasswordChanged;
  final VoidCallback onSubmitSuccess;

  const _ChangePasswordForm({
    super.key,
    required this.cardNumber,
    required this.currentPassword,
    required this.canConfirmNotifier,
    required this.onPasswordChanged,
    required this.onSubmitSuccess,
  });

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasValidated = false; // 标记是否已经触发过验证

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateCanConfirm() {
    // 使用 Future.microtask 避免在 build 时修改状态
    Future.microtask(() {
      // 只有在已经触发过验证后才实时更新
      if (_hasValidated) {
        widget.canConfirmNotifier.value =
            _formKey.currentState?.validate() ?? false;
      } else {
        // 未触发验证前，只检查是否有输入
        final hasInput =
            _newPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty;
        widget.canConfirmNotifier.value = hasInput;
      }
    });
  }

  // 供外部调用的提交方法
  void submitForm() {
    setState(() {
      _hasValidated = true;
    });

    // 触发验证
    if (_formKey.currentState?.validate() ?? false) {
      // 验证通过，执行提交
      widget.onPasswordChanged(_newPasswordController.text);
      Toast.success(message: '密码修改成功！卡号:${widget.cardNumber}');
      // 通知外部验证成功，可以关闭对话框
      widget.onSubmitSuccess();
    }
    // 如果验证失败，不做任何操作，对话框保持打开状态
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入新密码';
    }
    if (value.length < 6) {
      return '密码长度至少6位';
    }
    if (value == widget.currentPassword) {
      return '新密码不能与旧密码相同';
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _hasValidated
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      onChanged: _updateCanConfirm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoField(label: '技术卡号', value: widget.cardNumber),
          SizedBox(height: 20.h),
          _buildInfoField(label: '旧密码', value: widget.currentPassword),
          SizedBox(height: 20.h),
          _buildPasswordField(
            controller: _newPasswordController,
            label: '新密码',
            hint: '请输入新密码',
            obscureText: _obscureNewPassword,
            validator: _validateNewPassword,
            onToggleVisibility: () {
              setState(() => _obscureNewPassword = !_obscureNewPassword);
            },
          ),
          SizedBox(height: 20.h),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: '确认新密码',
            hint: '请再次输入新密码',
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            onToggleVisibility: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGrey,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required String? Function(String?) validator,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return TextStyle(fontSize: 14.sp, color: AppTheme.errorColor);
          }
          return TextStyle(fontSize: 14.sp, color: AppTheme.primaryColor);
        }),
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            size: 18.sp,
            color: Colors.black54,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
