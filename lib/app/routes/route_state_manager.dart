import '../../core/widgets/drawer.dart';

/// 路由清理回调类型
typedef CleanupCallback = void Function();

/// 路由清理函数类型
typedef CleanupFunction = void Function();

/// 路由清理配置
class RouteCleanupConfig {
  /// 路由路径
  final String routePath;

  /// 清理函数列表（用于删除 Controllers）
  final List<CleanupFunction> cleanupFunctions;

  /// 自定义清理回调（可选）
  final CleanupCallback? onCleanup;

  RouteCleanupConfig({
    required this.routePath,
    required this.cleanupFunctions,
    this.onCleanup,
  });
}

/// 路由状态管理 - 用于处理路由离开时的清理工作
class RouteStateManager {
  static String? _previousRoute;

  /// 路由清理配置映射
  static final Map<String, RouteCleanupConfig> _cleanupConfigMap = {};

  /// 注册路由清理配置
  static void registerCleanupConfig(RouteCleanupConfig config) {
    _cleanupConfigMap[config.routePath] = config;
  }

  /// 注册多个路由清理配置
  static void registerCleanupConfigs(List<RouteCleanupConfig> configs) {
    for (final config in configs) {
      registerCleanupConfig(config);
    }
  }

  /// 更新当前路由
  static void updateRoute(String currentRoute) {
    if (_previousRoute != null && _previousRoute != currentRoute) {
      // 路由切换时关闭抽屉
      if (CustomDrawer.isShowing) {
        CustomDrawer.hide();
      }
      _handleRouteExit(_previousRoute!);
    }
    _previousRoute = currentRoute;
  }

  /// 处理路由退出时的清理逻辑
  static void _handleRouteExit(String routePath) {
    final config = _cleanupConfigMap[routePath];
    if (config != null) {
      _executeCleanupFunctions(config.cleanupFunctions);
      config.onCleanup?.call();
    }
  }

  /// 执行清理函数
  static void _executeCleanupFunctions(List<CleanupFunction> functions) {
    for (final function in functions) {
      try {
        function();
      } catch (e) {
        print('Error during cleanup: $e');
      }
    }
  }

  /// 手动清理指定路由的 Controllers
  static void cleanupRoute(String routePath) {
    final config = _cleanupConfigMap[routePath];
    if (config != null) {
      _executeCleanupFunctions(config.cleanupFunctions);
      config.onCleanup?.call();
    }
  }

  /// 清空所有配置（用于测试或重置）
  static void clearAllConfigs() {
    _cleanupConfigMap.clear();
    _previousRoute = null;
  }

  /// 获取当前路由
  static String? get currentRoute => _previousRoute;

  /// 获取所有注册的清理配置
  static Map<String, RouteCleanupConfig> get cleanupConfigs =>
      Map.unmodifiable(_cleanupConfigMap);
}
