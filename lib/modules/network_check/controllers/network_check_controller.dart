import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/network_status.dart';
import '../../../data/services/network_check_service.dart';
import '../../../core/constants/network_config.dart';

/// 网络检测控制器
class NetworkCheckController extends GetxController {
  final NetworkCheckService _networkCheckService = NetworkCheckService();

  Timer? _autoCheckTimer;

  // 状态变量
  final Rx<NetworkCheckResult> externalConnectionStatus =
      NetworkCheckResult.pending().obs;

  final Rx<NetworkCheckResult> centerServerConnectionStatus =
      NetworkCheckResult.pending().obs;

  final Rx<NetworkCheckResult> externalPingStatus =
      NetworkCheckResult.pending().obs;

  final Rx<NetworkCheckResult> dnsPingStatus = NetworkCheckResult.pending().obs;

  final Rx<NetworkCheckResult> centerServerPingStatus =
      NetworkCheckResult.pending().obs;

  @override
  void onInit() {
    super.onInit();
    // 页面加载时自动执行检测
    checkAll();
    // 启动自动检测
    startAutoCheck();
  }

  @override
  void onClose() {
    // 停止自动检测
    print('close network');
    stopAutoCheck();
    super.onClose();
  }

  /// 启动自动检测
  void startAutoCheck() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = Timer.periodic(
      Duration(seconds: NetworkConfig.autoCheckInterval),
      (_) => checkAll(),
    );
  }

  /// 停止自动检测
  void stopAutoCheck() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = null;
  }

  /// 执行所有检测
  Future<void> checkAll() async {
    await Future.wait([
      checkExternalConnection(),
      checkCenterServerConnection(),
      pingExternal(),
      pingDnsServer(),
      pingCenterServer(),
    ]);
  }

  /// 检查外网连接
  Future<void> checkExternalConnection() async {
    externalConnectionStatus.value = NetworkCheckResult.checking();

    final result = await _networkCheckService.checkExternalConnection();
    externalConnectionStatus.value = result;
  }

  /// 检查中心服务器连接
  Future<void> checkCenterServerConnection() async {
    centerServerConnectionStatus.value = NetworkCheckResult.checking();

    final result = await _networkCheckService.checkCenterServerConnection();
    centerServerConnectionStatus.value = result;
  }

  /// Ping外网
  Future<void> pingExternal() async {
    externalPingStatus.value = NetworkCheckResult.checking();

    final result = await _networkCheckService.pingExternal();
    externalPingStatus.value = result;
  }

  /// Ping DNS服务器
  Future<void> pingDnsServer() async {
    dnsPingStatus.value = NetworkCheckResult.checking();

    final result = await _networkCheckService.pingDnsServer();
    dnsPingStatus.value = result;
  }

  /// Ping中心服务器
  Future<void> pingCenterServer() async {
    centerServerPingStatus.value = NetworkCheckResult.checking();

    final result = await _networkCheckService.pingCenterServer();
    centerServerPingStatus.value = result;
  }

  /// 获取状态显示文本
  String getStatusText(NetworkCheckResult result) {
    switch (result.status) {
      case NetworkCheckStatus.pending:
        return '待检测';
      case NetworkCheckStatus.checking:
        return '检测中...';
      case NetworkCheckStatus.success:
        if (result.latency != null) {
          return '正常 (${result.latency}ms)';
        }
        return '正常';
      case NetworkCheckStatus.failed:
        return result.errorMessage ?? '失败';
    }
  }
}
