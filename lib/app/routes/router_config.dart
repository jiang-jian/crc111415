import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import '../../modules/login/views/login_page.dart';
import '../../modules/login/controllers/login_controller.dart';
import '../../modules/login/controllers/quick_login_controller.dart';
import '../../modules/home/views/home_page.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/bind_cashier/views/bind_cashier_page.dart';
import '../../modules/bind_cashier/controllers/bind_cashier_controller.dart';
import '../../modules/cashier/views/cashier_page.dart';
import '../../modules/cashier/controllers/cashier_controller.dart';
import '../../modules/device_setup/views/device_setup_page.dart';
import '../../modules/device_setup/controllers/device_setup_controller.dart';
import '../../modules/notification_center/views/notification_center_page.dart';
import '../../modules/notification_center/controllers/notification_center_controller.dart';
import '../../modules/sunmi_customer_api/views/sunmi_customer_api_page.dart';
import '../../modules/sunmi_customer_api/controllers/sunmi_customer_api_controller.dart';
import '../../modules/settings/views/settings_page.dart';
import '../../modules/settings/controllers/settings_controller.dart';
import '../../modules/gift_exchange/views/gift_exchange_page.dart';
import '../../modules/gift_exchange/controllers/gift_exchange_controller.dart';
import '../../modules/customer_center/views/customer_center_page.dart';
import '../../modules/customer_center/controllers/customer_center_controller.dart';
import '../../modules/customer_center/controllers/customer_menu_controller.dart';
import '../../modules/network_check/controllers/network_check_controller.dart';
import '../../shared/layouts/shell_layout.dart';
import '../../shared/widgets/no_back_wrapper.dart';
import '../../shared/widgets/app_header_controller.dart';
import '../../shared/widgets/guide_overlay/guide_manager.dart';
import '../../core/storage/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/navigation_helper.dart';
import 'route_state_manager.dart';

/// GoRouter 配置
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  /// 全局 GoRouter 实例
  static GoRouter? _router;
  static GoRouter get router => _router!;

  static Widget _buildPageTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return PageTransition(
      type: PageTransitionType.rightToLeft,
      child: child,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    ).buildTransitions(context, animation, secondaryAnimation, child);
  }

  static GoRouter createRouter() {
    if (_router != null) {
      return _router!;
    }

    // 初始化路由清理配置
    _initializeRouteCleanupConfigs();

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: _getInitialLocation(),
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) {
            if (Get.isRegistered<LoginController>()) {
              Get.delete<LoginController>();
            }
            if (Get.isRegistered<QuickLoginController>()) {
              Get.delete<QuickLoginController>();
            }
            if (Get.isRegistered<NetworkCheckController>()) {
              Get.delete<NetworkCheckController>();
            }
            Get.put<LoginController>(LoginController());
            Get.put<QuickLoginController>(QuickLoginController());
            Get.put<NetworkCheckController>(NetworkCheckController());

            return CustomTransitionPage(
              key: state.pageKey,
              child: const NoBackWrapper(child: LoginPage()),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return PageTransition(
                      type: PageTransitionType.fade,
                      child: child,
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ).buildTransitions(
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    );
                  },
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 300),
            );
          },
        ),

        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            if (!Get.isRegistered<HomeController>()) {
              Get.lazyPut<HomeController>(() => HomeController());
            }
            if (!Get.isRegistered<AppHeaderController>()) {
              Get.lazyPut<AppHeaderController>(() => AppHeaderController());
            }

            // 首页显示引导
            if (state.matchedLocation == '/home') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GuideManager.init(context);
              });
            }

            return ShellLayout(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) {
                if (!Get.isRegistered<HomeController>()) {
                  Get.lazyPut<HomeController>(() => HomeController());
                }

                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const NoBackWrapper(child: HomePage()),
                  transitionsBuilder: _buildPageTransition,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                );
              },
            ),

            GoRoute(
              path: '/bind-cashier',
              name: 'bind-cashier',
              pageBuilder: (context, state) {
                if (Get.isRegistered<BindCashierController>()) {
                  Get.delete<BindCashierController>();
                }
                Get.put<BindCashierController>(BindCashierController());

                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const NoBackWrapper(child: BindCashierPage()),
                  transitionsBuilder: _buildPageTransition,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                );
              },
            ),

            GoRoute(
              path: '/cashier',
              name: 'cashier',
              pageBuilder: (context, state) {
                // 删除旧的 Controller 并创建新的
                if (Get.isRegistered<CashierController>()) {
                  Get.delete<CashierController>();
                }
                Get.put<CashierController>(CashierController());

                return CustomTransitionPage(
                  key: state.pageKey,
                  maintainState: false,
                  child: const CashierPage(),
                  transitionsBuilder: _buildPageTransition,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                );
              },
            ),

            GoRoute(
              path: '/device-setup',
              name: 'device-setup',
              pageBuilder: (context, state) {
                // 删除旧的 Controller 并创建新的
                if (Get.isRegistered<DeviceSetupController>()) {
                  Get.delete<DeviceSetupController>();
                }
                Get.put<DeviceSetupController>(DeviceSetupController());
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const DeviceSetupPage(),
                  transitionsBuilder: _buildPageTransition,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                );
              },
            ),
            GoRoute(
              path: '/notification-center',
              name: 'notification-center',
              pageBuilder: (context, state) {
                // 删除旧的 Controller 并创建新的
                if (Get.isRegistered<NotificationCenterController>()) {
                  Get.delete<NotificationCenterController>();
                }
                Get.put<NotificationCenterController>(
                  NotificationCenterController(),
                );

                return CustomTransitionPage(
                  key: state.pageKey,
                  maintainState: false,
                  child: const NotificationCenterPage(),
                  transitionsBuilder: _buildPageTransition,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                );
              },
            ),
            GoRoute(
              path: '/sunmi-customer-api',
              name: 'sunmi-customer-api',
              pageBuilder: (context, state) {
                if (!Get.isRegistered<SunmiCustomerApiController>()) {
                  Get.lazyPut<SunmiCustomerApiController>(
                    () => SunmiCustomerApiController(),
                  );
                }
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const SunmiCustomerApiPage(),
                  transitionsBuilder: _buildPageTransition,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                );
              },
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              pageBuilder: (context, state) {
                if (Get.isRegistered<SettingsController>()) {
                  Get.delete<SettingsController>();
                }
                Get.put<SettingsController>(SettingsController());
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const SettingsPage(),
                  transitionsBuilder: _buildPageTransition,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                );
              },
            ),
            GoRoute(
              path: '/gift-exchange',
              name: 'gift-exchange',
              pageBuilder: (context, state) {
                if (Get.isRegistered<GiftExchangeController>()) {
                  Get.delete<GiftExchangeController>();
                }
                Get.put<GiftExchangeController>(GiftExchangeController());
                return CustomTransitionPage(
                  key: state.pageKey,
                  maintainState: false,
                  child: const GiftExchangePage(),
                  transitionsBuilder: _buildPageTransition,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                );
              },
            ),

            GoRoute(
              path: '/customer-center',
              name: 'customer-center',
              pageBuilder: (context, state) {
                if (Get.isRegistered<CustomerCenterController>()) {
                  Get.delete<CustomerCenterController>();
                }
                if (Get.isRegistered<CustomerMenuController>()) {
                  Get.delete<CustomerMenuController>();
                }
                Get.put<CustomerCenterController>(CustomerCenterController());
                Get.put<CustomerMenuController>(CustomerMenuController());

                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const CustomerCenterPage(),
                  transitionsBuilder: _buildPageTransition,
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                );
              },
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        // 更新路由状态，处理路由离开时的清理
        RouteStateManager.updateRoute(state.matchedLocation);
        final storage = Get.find<StorageService>();
        final token = storage.getString(StorageKeys.token);
        final isLoggedIn = token != null && token.isNotEmpty;
        final isLoginPage = state.matchedLocation == '/login';

        if (!isLoggedIn) {
          return isLoginPage ? null : '/login';
        }
        if (isLoginPage) {
          return NavigationHelper.isBindCashier ? '/home' : '/bind-cashier';
        }

        return null;
      },
    );
    return _router!;
  }

  /// 全局导航方法 - go
  static void go(String location, {Object? extra}) {
    router.go(location, extra: extra);
  }

  /// 全局导航方法 - push
  static void push(String location, {Object? extra}) {
    final currentRoute = getCurrentRoute();
    if (currentRoute == location) return;
    router.push(location, extra: extra);
  }

  /// 全局导航方法 - pop
  static void pop<T extends Object?>([T? result]) {
    router.pop(result);
  }

  /// 全局导航方法 - replace
  static void replace(String location, {Object? extra}) {
    router.replace(location, extra: extra);
  }

  /// 获取当前路由
  static String getCurrentRoute() {
    return router.state.uri.path;
  }

  static String _getInitialLocation() {
    final storage = Get.find<StorageService>();
    final token = storage.getString(StorageKeys.token);

    if (token != null && token.isNotEmpty) {
      return NavigationHelper.isBindCashier ? '/home' : '/bind-cashier';
    }
    return '/login';
  }

  /// 初始化路由清理配置
  static void _initializeRouteCleanupConfigs() {
    RouteStateManager.registerCleanupConfigs([
      // Settings 路由清理配置
      RouteCleanupConfig(
        routePath: '/settings',
        cleanupFunctions: [() => Get.delete<SettingsController>(force: true)],
      ),
      // Bind Cashier 路由清理配置
      RouteCleanupConfig(
        routePath: '/bind-cashier',
        cleanupFunctions: [
          () => Get.delete<BindCashierController>(force: true),
        ],
      ),
      // Device Setup 路由清理配置
      RouteCleanupConfig(
        routePath: '/device-setup',
        cleanupFunctions: [
          () => Get.delete<DeviceSetupController>(force: true),
        ],
      ),
      // Notification Center 路由清理配置
      RouteCleanupConfig(
        routePath: '/notification-center',
        cleanupFunctions: [
          () => Get.delete<NotificationCenterController>(force: true),
        ],
      ),
      // Sign Coin 路由清理配置
      RouteCleanupConfig(
        routePath: '/sign-coin',
        cleanupFunctions: [() => Get.delete<SignCoinController>(force: true)],
      ),
      // Gift Exchange 路由清理配置
      RouteCleanupConfig(
        routePath: '/gift-exchange',
        cleanupFunctions: [
          () => Get.delete<GiftExchangeController>(force: true),
        ],
      ),
      // Customer Center 路由清理配置
      RouteCleanupConfig(
        routePath: '/customer-center',
        cleanupFunctions: [
          () => Get.delete<CustomerCenterController>(force: true),
          () => Get.delete<CustomerMenuController>(force: true),
        ],
      ),
    ]);
  }
}
