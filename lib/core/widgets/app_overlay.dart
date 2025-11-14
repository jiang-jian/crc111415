import 'package:flutter/material.dart';

/// 全局 Overlay 管理器
/// 统一管理 Toast、Loading 和 Dialog 的 Overlay Key
class AppOverlay {
  // Toast 使用的 Overlay（最上层）
  static final GlobalKey<OverlayState> _toastOverlayKey =
      GlobalKey<OverlayState>();

  // Loading 使用的 Overlay（中间层）
  static final GlobalKey<OverlayState> _loadingOverlayKey =
      GlobalKey<OverlayState>();

  // Dialog 使用的 Overlay（中间层）
  static final GlobalKey<OverlayState> _dialogOverlayKey =
      GlobalKey<OverlayState>();

  /// 获取 Toast Overlay Key
  static GlobalKey<OverlayState> get toastOverlayKey => _toastOverlayKey;

  /// 获取 Loading Overlay Key
  static GlobalKey<OverlayState> get loadingOverlayKey => _loadingOverlayKey;

  /// 获取 Dialog Overlay Key
  static GlobalKey<OverlayState> get dialogOverlayKey => _dialogOverlayKey;
}
