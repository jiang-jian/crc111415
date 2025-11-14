import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:ailand_pos/core/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'add_technical_card_view.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/deactivate_card_dialog.dart';

class CardRegistrationView extends StatefulWidget {
  const CardRegistrationView({super.key});

  @override
  State<CardRegistrationView> createState() => _CardRegistrationViewState();
}

class _CardRegistrationViewState extends State<CardRegistrationView> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _mockData = [
    {
      'cardNumber': '1001',
      'password': '123456',
      'operationTime': '2024-01-15 10:30:25',
      'operator': '张三',
    },
    {
      'cardNumber': '1002',
      'password': '654321',
      'operationTime': '2024-01-16 14:20:10',
      'operator': '李四',
    },
    {
      'cardNumber': '1003',
      'password': '111222',
      'operationTime': '2024-01-17 09:15:30',
      'operator': '王五',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '技术卡登记',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(child: _buildDataTable()),
          SizedBox(height: 24.h),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            child: _buildTableRow(
              isHeader: true,
              selected: false,
              cardNumber: '技术卡号',
              password: '密码',
              operationTime: '操作时间',
              operator: '操作人',
            ),
          ),
          Divider(height: 1.h, color: AppTheme.borderColor),
          Expanded(
            child: ListView.separated(
              itemCount: _mockData.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1.h, color: AppTheme.borderColor),
              itemBuilder: (context, index) {
                final item = _mockData[index];
                return _buildTableRow(
                  isHeader: false,
                  selected: _selectedIndex == index,
                  cardNumber: item['cardNumber']!,
                  password: item['password']!,
                  operationTime: item['operationTime']!,
                  operator: item['operator']!,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required bool isHeader,
    required bool selected,
    required String cardNumber,
    required String password,
    required String operationTime,
    required String operator,
    VoidCallback? onTap,
  }) {
    final textStyle = TextStyle(
      fontSize: isHeader ? 16.sp : 15.sp,
      fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
      color: isHeader ? AppTheme.textPrimary : AppTheme.textPrimary,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: selected && !isHeader
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 60.w,
              child: isHeader
                  ? Text('选择', style: textStyle)
                  : Radio<bool>(
                      value: true,
                      groupValue: selected,
                      onChanged: (_) => onTap?.call(),
                      fillColor: WidgetStateProperty.all(AppTheme.primaryColor),
                    ),
            ),
            Expanded(flex: 2, child: Text(cardNumber, style: textStyle)),
            Expanded(flex: 2, child: Text(password, style: textStyle)),
            Expanded(flex: 3, child: Text(operationTime, style: textStyle)),
            Expanded(flex: 2, child: Text(operator, style: textStyle)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          label: '添加技术卡',
          backgroundColor: AppTheme.primaryColor,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTechnicalCardView()),
          ),
        ),
        SizedBox(width: AppTheme.spacingDefault),
        _buildButton(
          label: '修改密码',
          backgroundColor: const Color(0xFF9C27B0),
          onPressed: _handleChangePassword,
        ),
        SizedBox(width: AppTheme.spacingDefault),
        _buildButton(
          label: '注销',
          backgroundColor: const Color(0xFF9E9E9E),
          onPressed: _handleDeactivateCard,
        ),
      ],
    );
  }

  void _handleChangePassword() {
    if (!_isValidSelection()) return;

    final selectedCard = _mockData[_selectedIndex];
    ChangePasswordDialog.show(
      context,
      cardNumber: selectedCard['cardNumber']!,
      currentPassword: selectedCard['password']!,
      onPasswordChanged: (newPassword) {
        setState(() {
          _mockData[_selectedIndex]['password'] = newPassword;
          _mockData[_selectedIndex]['operationTime'] = DateTime.now()
              .toString()
              .substring(0, 19);
        });
      },
    );
  }

  void _handleDeactivateCard() {
    if (!_isValidSelection()) return;

    final selectedCard = _mockData[_selectedIndex];
    DeactivateCardDialog.show(
      context,
      cardNumber: selectedCard['cardNumber']!,
      onCardDeactivated: (_) {
        setState(() {
          _mockData.removeAt(_selectedIndex);
          _selectedIndex = _mockData.isNotEmpty ? 0 : -1;
        });
      },
    );
  }

  bool _isValidSelection() {
    if (_selectedIndex >= 0 && _selectedIndex < _mockData.length) {
      return true;
    }
    Toast.error(message: '请先选择一张技术卡');
    return false;
  }

  Widget _buildButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 140.w,
      height: 50.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          splashColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.2),
          child: Center(
            child: Text(
              label,
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
