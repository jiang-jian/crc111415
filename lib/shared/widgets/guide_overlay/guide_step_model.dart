import 'package:flutter/material.dart';

/// 引导步骤配置（基于Rect坐标）
class GuideStepConfig {
  /// 高亮区域的矩形
  final Rect highlightRect;

  /// 引导标题
  final String title;

  /// 引导描述文本
  final String description;

  /// 高亮区域的圆角半径
  final double borderRadius;

  /// 提示卡片相对于高亮区域的位置偏移
  final Offset? tipOffset;

  const GuideStepConfig({
    required this.highlightRect,
    required this.title,
    required this.description,
    this.borderRadius = 8.0,
    this.tipOffset,
  });
}
