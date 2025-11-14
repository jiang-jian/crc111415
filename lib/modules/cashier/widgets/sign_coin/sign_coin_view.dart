/// SignCoinView
/// 签币视图 - 替换购物车区域显示

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_theme.dart';
import '../../controllers/sign_coin_controller.dart';
import 'sign_coin_password_dialog.dart';

class SignCoinView extends StatelessWidget {
  const SignCoinView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignCoinController>();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: '签币人',
                    required: true,
                    child: Obx(
                      () => Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: controller.persons.map((person) {
                          final isSelected =
                              controller.selectedPersonId.value == person.id;
                          return _buildButton(
                            text: person.name,
                            icon: Icons.person,
                            isSelected: isSelected,
                            onTap: () => controller.selectPerson(person.id),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildSection(
                    title: '签增原因',
                    required: true,
                    child: Obx(
                      () => Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: controller.reasons.map((reason) {
                          final isSelected =
                              controller.selectedReason.value == reason;
                          return _buildButton(
                            text: reason,
                            isSelected: isSelected,
                            onTap: () => controller.selectReason(reason),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildSection(
                    title: '签增数量',
                    required: true,
                    child: _QuantityInput(controller: controller),
                  ),
                  SizedBox(height: 32.h),
                  _buildSection(
                    title: '备注',
                    child: _RemarkInput(controller: controller),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, controller),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            ),
            child: Icon(
              Icons.edit_note_outlined,
              size: 24.sp,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: AppTheme.spacingM),
          Text(
            '签币',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    bool required = false,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (required) ...[
              SizedBox(width: 6.w),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 17.sp,
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              SizedBox(width: AppTheme.spacingS),
              Text(
                '(可选)',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 16.h),
        child,
      ],
    );
  }

  Widget _buildButton({
    required String text,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final padding = EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h);

    if (isSelected) {
      return icon != null
          ? ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(padding: padding),
              icon: Icon(icon, size: 20.sp),
              label: Text(text),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(padding: padding),
              child: Text(text),
            );
    }

    return icon != null
        ? OutlinedButton.icon(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(padding: padding),
            icon: Icon(icon, size: 20.sp),
            label: Text(text),
          )
        : OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(padding: padding),
            child: Text(text),
          );
  }

  Widget _buildBottomBar(BuildContext context, SignCoinController controller) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.reset,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
              ),
              child: const Text('重置'),
            ),
          ),
          SizedBox(width: AppTheme.spacingDefault),
          Expanded(
            flex: 2,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isFormValid
                    ? () => SignCoinPasswordDialog.show(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 18.h,
                  ),
                ),
                child: const Text('确定签币'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityInput extends StatefulWidget {
  final SignCoinController controller;

  const _QuantityInput({required this.controller});

  @override
  State<_QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<_QuantityInput> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    ever(widget.controller.quantity, (value) {
      if (value.isEmpty && _textController.text.isNotEmpty) {
        _textController.clear();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: widget.controller.updateQuantity,
      decoration: InputDecoration(
        hintText: '请输入签增数量',
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 20.w),
          child: Center(
            widthFactor: 0,
            child: Text(
              '币',
              style: TextStyle(fontSize: 16.sp, color: AppTheme.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemarkInput extends StatefulWidget {
  final SignCoinController controller;

  const _RemarkInput({required this.controller});

  @override
  State<_RemarkInput> createState() => _RemarkInputState();
}

class _RemarkInputState extends State<_RemarkInput> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    ever(widget.controller.remark, (value) {
      if (value.isEmpty && _textController.text.isNotEmpty) {
        _textController.clear();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      maxLines: 4,
      onChanged: widget.controller.updateRemark,
      decoration: const InputDecoration(
        hintText: '请输入备注信息（可选）',
        alignLabelWithHint: true,
      ),
    );
  }
}
