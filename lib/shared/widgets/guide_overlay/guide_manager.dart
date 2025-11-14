import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/storage/storage_service.dart';
import 'guide_overlay.dart';
import 'guide_step_model.dart';

/// 首页引导管理器
class GuideManager {
  static const String _guideCompletedKey = 'home_guide_completed';
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// 初始化引导（在首页调用）
  static void init(BuildContext context) {
    // 检查是否已完成引导
    final storage = Get.find<StorageService>();
    if (storage.getBool(_guideCompletedKey) ?? false) {
      return;
    }

    // 延迟显示，确保页面渲染完成
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        showGuide(context);
      }
    });
  }

  /// 显示引导
  static void showGuide(BuildContext context) {
    if (_isShowing) return;

    final steps = _createGuideSteps();
    _isShowing = true;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => GuideOverlay(
        steps: steps,
        onComplete: _completeGuide,
        onSkip: _completeGuide,
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  /// 创建引导步骤（响应式布局）
  ///
  /// 💡 调整说明：
  /// - 使用 .w 和 .h 适配不同分辨率
  /// - 基准分辨率：1920x1080
  /// - 坐标会根据实际屏幕尺寸自动缩放
  static List<GuideStepConfig> _createGuideSteps() {
    return [
      // 跑马灯通知
      GuideStepConfig(
        highlightRect: Rect.fromLTWH(700.w, 16.h, 950.w, 40.h),
        title: '跑马灯通知',
        description: '这里会滚动展示系统通知、活动信息等重要消息，请留意查看。',
        borderRadius: 8.0,
      ),

      // 客服与商户信息
      GuideStepConfig(
        highlightRect: Rect.fromLTWH(1500.w, 105.h, 380.w, 40.h),
        title: '客服与商户信息',
        description: '这里显示客服电话和您的商户编码，遇到问题可随时联系客服。',
        borderRadius: 8.0,
      ),

      // 消息通知与帮助（右上角按钮区）
      GuideStepConfig(
        highlightRect: Rect.fromLTWH(1700.w, 16.h, 200.w, 40.h),
        title: '消息通知与帮助中心',
        description: '点击通知图标查看系统消息提醒，点击帮助图标可获取使用指南和常见问题解答。',
        borderRadius: 20.0,
      ),

      // 快速收银按钮
      GuideStepConfig(
        highlightRect: Rect.fromLTWH(40.w, 150.h, 360.w, 300.h),
        title: '快速收银',
        description: '点击此处可快速进入收银台，开始为顾客结账服务。',
        borderRadius: 12.0,
      ),
    ];
  }

  /// 完成引导
  static void _completeGuide() {
    final storage = Get.find<StorageService>();
    storage.setBool(_guideCompletedKey, true);
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }

  /// 重置引导状态（用于测试）
  static void resetGuide() {
    final storage = Get.find<StorageService>();
    storage.setBool(_guideCompletedKey, false);
  }
}
