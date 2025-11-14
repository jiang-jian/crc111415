import 'package:get/get.dart';
import '../../app/routes/router_config.dart';
import '../../modules/login/controllers/login_controller.dart';
import '../../modules/login/controllers/quick_login_controller.dart';
import '../../modules/network_check/controllers/network_check_controller.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/bind_cashier/controllers/bind_cashier_controller.dart';
import '../../modules/cashier/controllers/cashier_controller.dart';
import '../../modules/device_setup/controllers/device_setup_controller.dart';
import '../../modules/notification_center/controllers/notification_center_controller.dart';
import '../../modules/sunmi_customer_api/controllers/sunmi_customer_api_controller.dart';
import '../../modules/settings/controllers/settings_controller.dart';
import '../../shared/widgets/app_header_controller.dart';

/// 导航辅助类 - 处理路由跳转时的 Controller 清理
///
/// 使用场景：
/// 1. 登录成功后跳转首页，自动清理登录相关 Controller
/// 2. 退出登录时跳转登录页，自动清理首页相关 Controller
///
/// 注意：清理操作会延迟执行，等待路由动画完成后再清理，避免动画期间报错
class NavigationHelper {
  /// 路由动画时长（毫秒）- 需要与 router_config.dart 中的动画时长保持一致
  static const int _transitionDuration = 350;

  /// 额外的安全延迟（毫秒）- 确保动画完全结束
  static const int _safetyDelay = 500;

  /// 总延迟时长
  static int get _totalDelay => _transitionDuration + _safetyDelay;

  // 是否绑定了收银点
  static bool _isBindCashier = true;

  /// 获取是否绑定了收银点
  static bool get isBindCashier => _isBindCashier;

  /// 设置是否绑定了收银点
  static void setIsBindCashier(bool value) {
    _isBindCashier = value;
  }

  /// 从登录页跳转到首页（清理登录相关 Controller）
  static void loginToHome() {
    // 判断是否绑定了收银点，如果没绑定则跳转到 bind-cashier
    if (_isBindCashier) {
      AppRouter.replace('/home');
    } else {
      AppRouter.replace('/bind-cashier');
    }
    // 延迟清理，等待路由动画完成
    Future.delayed(Duration(milliseconds: _totalDelay), () {
      _deleteLoginControllers();
    });
  }

  /// 从首页退出登录（清理首页相关 Controller）
  static void homeToLogin() {
    // 先跳转
    AppRouter.replace('/login');

    // 延迟清理，等待路由动画完成
    Future.delayed(Duration(milliseconds: _totalDelay), () {
      _deleteHomeControllers();
    });
  }

  /// 清理登录页相关的 Controller
  static void _deleteLoginControllers() {
    _safeDeleteController<LoginController>('LoginController');
    _safeDeleteController<QuickLoginController>('QuickLoginController');
    _safeDeleteController<NetworkCheckController>('NetworkCheckController');
  }

  /// 清理首页相关的 Controller
  static void _deleteHomeControllers() {
    _safeDeleteController<HomeController>('HomeController');
    _safeDeleteController<BindCashierController>('BindCashierController');
    _safeDeleteController<AppHeaderController>('AppHeaderController');
    _safeDeleteController<CashierController>('CashierController');
    _safeDeleteController<DeviceSetupController>('DeviceSetupController');
    _safeDeleteController<NotificationCenterController>(
      'NotificationCenterController',
    );
    _safeDeleteController<SunmiCustomerApiController>(
      'SunmiCustomerApiController',
    );
    _safeDeleteController<SettingsController>('SettingsController');
  }

  /// 安全地删除 Controller（带类型检查）
  static void _safeDeleteController<T>(String name) {
    try {
      if (Get.isRegistered<T>()) {
        Get.delete<T>(force: true);
      }
    } catch (e) {
      print('⚠️ 清理 $name 失败: $e');
    }
  }

  /// 通用的 Controller 清理方法（供外部使用）
  static void deleteController<T>({bool force = false}) {
    try {
      if (Get.isRegistered<T>()) {
        Get.delete<T>(force: force);
      }
    } catch (e) {
      print('⚠️ 清理 ${T.toString()} 失败: $e');
    }
  }
}
