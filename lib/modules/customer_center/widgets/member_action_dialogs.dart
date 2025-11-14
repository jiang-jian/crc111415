/// MemberActionDialogs
/// 会员操作对话框集合
/// 作者：AI 自动生成
/// 更新时间：2025-11-12

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/dialog.dart';
import '../../../core/widgets/toast.dart';
import '../controllers/member_query_controller.dart';

class MemberActionDialogs {
  static Future<void> showChangePasswordDialog(
    BuildContext context,
    MemberQueryController controller,
  ) async {
    final canConfirm = ValueNotifier<bool>(false);
    final formKey = GlobalKey<_ChangePasswordFormState>();

    await AppDialog.custom(
      title: '修改卡密',
      content: _ChangePasswordForm(
        key: formKey,
        cardNumber: controller.memberInfo.value?.cardNumber ?? '',
        canConfirmNotifier: canConfirm,
        onPasswordChanged: (newPassword) {
          controller.handleChangePassword(newPassword);
        },
        onSubmitSuccess: () {
          AppDialog.hide(true);
        },
      ),
      confirmText: '确定',
      width: 500.w,
      barrierDismissible: false,
      canConfirmNotifier: canConfirm,
      autoCloseOnConfirm: false,
      onConfirm: () {
        formKey.currentState?.submitForm();
      },
    );
  }

  static Future<bool> showLogoutConfirmDialog(BuildContext context) async {
    return await AppDialog.confirm(
      title: '退出登录',
      message: '确定要退出当前会员登录吗？',
      confirmText: '确定',
      cancelText: '取消',
      width: 400.w,
      isDanger: true,
    );
  }

  static Future<bool> showLossReportConfirmDialog(BuildContext context) async {
    return await AppDialog.confirm(
      title: '挂失确认',
      message: '确定要挂失该会员卡吗？挂失后该卡将无法使用。',
      confirmText: '确定挂失',
      cancelText: '取消',
      width: 400.w,
      isDanger: true,
    );
  }

  static void showAssetAllocationDialog(
    BuildContext context,
    MemberQueryController controller,
  ) {
    final gameCoinsController = TextEditingController();
    final lotteryController = TextEditingController();

    AppDialog.custom(
      title: '资产分配',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNumberField('游戏币', gameCoinsController),
          SizedBox(height: 16.h),
          _buildNumberField('彩票', lotteryController),
          SizedBox(height: 16.h),
          Text(
            '* 资产分配后将从主卡扣除对应数量',
            style: TextStyle(fontSize: 12.sp, color: AppTheme.warningColor),
          ),
        ],
      ),
      confirmText: '确定',
      cancelText: '取消',
      width: 400.w,
      onConfirm: () {
        controller.handleAssetAllocation();
        AppDialog.hide();
      },
    );
  }

  static void showBindEmailDialog(
    BuildContext context,
    MemberQueryController controller,
  ) {
    final emailController = TextEditingController();
    final codeController = TextEditingController();

    AppDialog.custom(
      title: '绑定邮箱',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: '邮箱地址',
              hintText: '请输入邮箱地址',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusDefault,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: '验证码',
                    hintText: '请输入验证码',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusDefault,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              ElevatedButton(
                onPressed: () {
                  Toast.success(message: '验证码已发送');
                },
                child: Text('发送验证码', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
        ],
      ),
      confirmText: '确定',
      cancelText: '取消',
      width: 500.w,
      onConfirm: () {
        if (emailController.text.isEmpty) {
          Toast.error(message: '请输入邮箱地址');
          return;
        }
        controller.handleBindEmail(emailController.text);
        AppDialog.hide();
      },
    );
  }

  static void showBindWatchDialog(
    BuildContext context,
    MemberQueryController controller,
  ) {
    final watchIdController = TextEditingController();

    AppDialog.custom(
      title: '绑定手表ID',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: watchIdController,
            decoration: InputDecoration(
              labelText: '手表ID',
              hintText: '请输入手表ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusDefault,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '* 请确保手表ID正确，绑定后不可修改',
            style: TextStyle(fontSize: 12.sp, color: AppTheme.warningColor),
          ),
        ],
      ),
      confirmText: '确定',
      cancelText: '取消',
      width: 400.w,
      onConfirm: () {
        if (watchIdController.text.isEmpty) {
          Toast.error(message: '请输入手表ID');
          return;
        }
        controller.handleBindWatch(watchIdController.text);
        AppDialog.hide();
      },
    );
  }

  static Widget _buildNumberField(
    String label,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: '请输入$label数量',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        ),
      ),
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  final String cardNumber;
  final ValueNotifier<bool> canConfirmNotifier;
  final Function(String newPassword) onPasswordChanged;
  final VoidCallback onSubmitSuccess;

  const _ChangePasswordForm({
    super.key,
    required this.cardNumber,
    required this.canConfirmNotifier,
    required this.onPasswordChanged,
    required this.onSubmitSuccess,
  });

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasValidated = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateCanConfirm() {
    Future.microtask(() {
      if (_hasValidated) {
        widget.canConfirmNotifier.value =
            _formKey.currentState?.validate() ?? false;
      } else {
        final hasInput =
            _oldPasswordController.text.isNotEmpty &&
            _newPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty;
        widget.canConfirmNotifier.value = hasInput;
      }
    });
  }

  void submitForm() {
    setState(() {
      _hasValidated = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      widget.onPasswordChanged(_newPasswordController.text);
      Toast.success(message: '密码修改成功！卡号:${widget.cardNumber}');
      widget.onSubmitSuccess();
    }
  }

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入原密码';
    }
    if (value.length < 6) {
      return '密码长度至少6位';
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
    if (value == _oldPasswordController.text) {
      return '新密码不能与原密码相同';
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
          _buildPasswordField(
            controller: _oldPasswordController,
            label: '原密码',
            hint: '请输入原密码',
            obscureText: _obscureOldPassword,
            validator: _validateOldPassword,
            onToggleVisibility: () {
              setState(() => _obscureOldPassword = !_obscureOldPassword);
            },
          ),
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
