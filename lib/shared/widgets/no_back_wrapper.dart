import 'package:flutter/material.dart';

/// 禁止返回的包装器
/// 用于登录页和首页等不允许返回的页面
class NoBackWrapper extends StatelessWidget {
  final Widget child;

  const NoBackWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁止返回
      child: child,
    );
  }
}
