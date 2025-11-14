import 'package:ailand_pos/app/theme/app_theme.dart';
import 'package:ailand_pos/core/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/services/external_card_reader_service.dart';

class AddTechnicalCardView extends StatefulWidget {
  const AddTechnicalCardView({super.key});

  @override
  State<AddTechnicalCardView> createState() => _AddTechnicalCardViewState();
}

class _AddTechnicalCardViewState extends State<AddTechnicalCardView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _cardNumberController;
  late final ExternalCardReaderService _service;
  String? _lastCardUid;
  bool _hasProcessedSuccess = false;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();

    // 初始化动画控制器（紫色渐变呼吸效果）
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    try {
      _service = Get.find<ExternalCardReaderService>();
    } catch (e) {
      _service = Get.put(ExternalCardReaderService());
      _service.init();
    }

    // 监听卡片数据变化
    ever(_service.cardData, (cardData) {
      if (mounted &&
          cardData != null &&
          cardData['isValid'] == true &&
          !_hasProcessedSuccess) {
        _hasProcessedSuccess = true;

        final cardUid = cardData['uid'];
        if (cardUid != null && cardUid != 'Unknown') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _cardNumberController.text != cardUid) {
              _cardNumberController.text = cardUid;
              _lastCardUid = cardUid;
              Future.delayed(const Duration(seconds: 1), () {
                _hasProcessedSuccess = false;
              });
            }
          });
        }
      }
    });

    // 监听错误状态
    ever(_service.lastError, (error) {
      if (mounted && error != null) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _service.lastError.value = null;
            _hasProcessedSuccess = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.textPrimary,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '添加技术卡',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 3,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 读卡器类型
                _buildCardReaderType(),

                SizedBox(height: 32.h),

                // 2. 读卡器状态
                _buildCardReaderStatus(),

                SizedBox(height: 32.h),

                // 3. 卡面卡号
                _buildCardNumberInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardReaderType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel('读卡器类型'),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGrey,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
          ),
          child: Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: AppTheme.successColor,
                size: 20.sp,
              ),
              SizedBox(width: AppTheme.spacingM),
              Text(
                '感应式IC卡（M1芯片）',
                style: TextStyle(fontSize: 18.sp, color: AppTheme.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardReaderStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel('读卡器状态'),
        SizedBox(height: 12.h),
        Obx(() {
          final selectedDevice = _service.selectedReader.value;
          final isConnected = selectedDevice != null;
          final isScanning = _service.isScanning.value;

          return Container(
            padding: EdgeInsets.all(AppTheme.spacingDefault),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusDefault),
            ),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: isConnected
                        ? AppTheme.successColor
                        : AppTheme.borderColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppTheme.spacingM),
                Text(
                  isConnected ? '已连接就绪' : '未连接',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: isConnected
                        ? AppTheme.successColor
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (!isConnected)
                  TextButton(
                    onPressed: isScanning
                        ? null
                        : () => _service.scanUsbReaders(),
                    child: Text(isScanning ? '扫描中...' : '连接读卡器'),
                  )
                else
                  IconButton(
                    onPressed: isScanning
                        ? null
                        : () => _service.scanUsbReaders(),
                    icon: Icon(
                      Icons.refresh,
                      color: isScanning
                          ? AppTheme.textSecondary
                          : AppTheme.primaryColor,
                      size: 24.sp,
                    ),
                  ),
              ],
            ),
          );
        }),
        Obx(() {
          final selectedDevice = _service.selectedReader.value;
          if (selectedDevice != null) {
            return Container(
              margin: EdgeInsets.only(top: 12.h),
              padding: EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusDefault,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.usb, size: 18.sp, color: AppTheme.successColor),
                  SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      selectedDevice.displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        _buildGradientPrompt(),
      ],
    );
  }

  Widget _buildCardNumberInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel('卡面卡号'),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final cardData = _service.cardData.value;
                final cardUid = cardData?['uid'];

                if (cardUid != null &&
                    cardUid != 'Unknown' &&
                    cardUid != _lastCardUid) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _cardNumberController.text = cardUid;
                    _lastCardUid = cardUid;
                  });
                }

                return TextField(
                  controller: _cardNumberController,
                  decoration: const InputDecoration(
                    labelText: '请输入卡面卡号',
                    hintText: '请输入卡面卡号',
                  ),
                  style: TextStyle(fontSize: 18.sp),
                );
              }),
            ),
            SizedBox(width: AppTheme.spacingM),
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: _handleAddCard,
                child: Text(
                  '添加',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildCardStatusPrompt(),
      ],
    );
  }

  Widget _buildGradientPrompt() {
    return Obx(() {
      final selectedDevice = _service.selectedReader.value;
      final isReading = _service.isReading.value;
      final cardData = _service.cardData.value;
      final lastError = _service.lastError.value;

      final shouldShow =
          selectedDevice != null &&
          !isReading &&
          cardData == null &&
          lastError == null;

      return AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          final gradientPosition = _shimmerAnimation.value;

          return Container(
            margin: EdgeInsets.only(top: 16.h),
            height: 50.h,
            alignment: Alignment.centerLeft,
            child: AnimatedOpacity(
              opacity: shouldShow ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  _buildGradientIcon(gradientPosition),
                  SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _buildGradientText(
                      '请将技术卡放置在读卡器上，系统将自动读取卡号',
                      gradientPosition,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCardStatusPrompt() {
    return Obx(() {
      final selectedDevice = _service.selectedReader.value;
      final cardData = _service.cardData.value;
      final isManualReading = _service.isManualReading.value;
      final lastError = _service.lastError.value;

      String? displayText;
      IconData? displayIcon;
      bool shouldShow = false;

      if (selectedDevice != null) {
        if (lastError != null) {
          displayText = '读卡失败：$lastError';
          displayIcon = Icons.error_outline;
          shouldShow = true;
        } else if (cardData != null && cardData['isValid'] == true) {
          displayText = '已读取到卡片：${cardData['uid']}';
          displayIcon = Icons.check_circle;
          shouldShow = true;
        } else if (isManualReading) {
          displayText = '正在读取卡片...';
          displayIcon = Icons.credit_card;
          shouldShow = true;
        }
      }

      return AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          final gradientPosition = _shimmerAnimation.value;

          return Container(
            margin: EdgeInsets.only(top: 12.h),
            height: 50.h,
            alignment: Alignment.centerLeft,
            child: AnimatedOpacity(
              opacity: shouldShow ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: displayText != null
                  ? Row(
                      children: [
                        if (displayIcon != null)
                          _buildGradientIcon(
                            gradientPosition,
                            icon: displayIcon,
                          ),
                        if (displayIcon != null)
                          SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: _buildGradientText(
                            displayText,
                            gradientPosition,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      );
    });
  }

  Widget _buildGradientIcon(double gradientPosition, {IconData? icon}) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          AppTheme.primaryColor,
          const Color(0xFFE91E63),
          const Color(0xFFBA68C8),
          const Color(0xFFE91E63),
          AppTheme.primaryColor,
        ],
        stops: [
          (gradientPosition - 0.4).clamp(0.0, 1.0),
          (gradientPosition - 0.2).clamp(0.0, 1.0),
          gradientPosition.clamp(0.0, 1.0),
          (gradientPosition + 0.2).clamp(0.0, 1.0),
          (gradientPosition + 0.4).clamp(0.0, 1.0),
        ],
      ).createShader(bounds),
      child: Icon(icon ?? Icons.credit_card, size: 20.sp, color: Colors.white),
    );
  }

  Widget _buildGradientText(String text, double gradientPosition) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          AppTheme.primaryColor,
          const Color(0xFFE91E63),
          const Color(0xFFBA68C8),
          const Color(0xFFE91E63),
          AppTheme.primaryColor,
        ],
        stops: [
          (gradientPosition - 0.4).clamp(0.0, 1.0),
          (gradientPosition - 0.2).clamp(0.0, 1.0),
          gradientPosition.clamp(0.0, 1.0),
          (gradientPosition + 0.2).clamp(0.0, 1.0),
          (gradientPosition + 0.4).clamp(0.0, 1.0),
        ],
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }

  void _handleAddCard() {
    final cardNumber = _cardNumberController.text.trim();
    if (cardNumber.isEmpty) {
      Toast.error(message: '请输入卡面卡号');
      return;
    }

    Toast.success(message: '保存功能开发中，卡号: $cardNumber');
  }

  Widget _buildRequiredLabel(String label) {
    return Row(
      children: [
        Text(
          '*',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: AppTheme.spacingXS),
        Text(
          label,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
