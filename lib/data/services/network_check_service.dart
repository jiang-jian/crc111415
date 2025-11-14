import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/network_status.dart';
import '../../core/constants/network_config.dart';

/// 网络检测服务
class NetworkCheckService {
  final Connectivity _connectivity = Connectivity();

  /// 检查外网连接
  Future<NetworkCheckResult> checkExternalConnection() async {
    try {
      final result = await InternetAddress.lookup(
        NetworkConfig.externalPingHost,
      ).timeout(Duration(seconds: NetworkConfig.checkTimeout));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return NetworkCheckResult.success();
      } else {
        return NetworkCheckResult.failed('无法解析域名');
      }
    } on SocketException catch (e) {
      return NetworkCheckResult.failed('连接失败: ${e.message}');
    } on TimeoutException {
      return NetworkCheckResult.failed('连接超时');
    } catch (e) {
      return NetworkCheckResult.failed('未知错误: $e');
    }
  }

  /// 检查中心服务器连接
  Future<NetworkCheckResult> checkCenterServerConnection() async {
    try {
      final result = await InternetAddress.lookup(
        NetworkConfig.centerServerHost,
      ).timeout(Duration(seconds: NetworkConfig.checkTimeout));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return NetworkCheckResult.success();
      } else {
        return NetworkCheckResult.failed('无法解析服务器域名');
      }
    } on SocketException catch (e) {
      return NetworkCheckResult.failed('服务器连接失败: ${e.message}');
    } on TimeoutException {
      return NetworkCheckResult.failed('服务器连接超时');
    } catch (e) {
      return NetworkCheckResult.failed('服务器连接错误: $e');
    }
  }

  /// Ping外网
  Future<NetworkCheckResult> pingExternal() async {
    return await _performPing(NetworkConfig.externalPingHost);
  }

  /// Ping DNS服务器
  Future<NetworkCheckResult> pingDnsServer() async {
    return await _performPing(NetworkConfig.dnsServerHost);
  }

  /// Ping中心服务器
  Future<NetworkCheckResult> pingCenterServer() async {
    return await _performPing(NetworkConfig.centerServerHost);
  }

  /// 执行Ping操作
  Future<NetworkCheckResult> _performPing(String host) async {
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < NetworkConfig.pingRetryCount; i++) {
      try {
        final result = await InternetAddress.lookup(
          host,
        ).timeout(Duration(seconds: NetworkConfig.pingTimeout));

        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('result: $result');
          stopwatch.stop();
          return NetworkCheckResult.success(
            latency: stopwatch.elapsedMilliseconds,
          );
        }
      } on SocketException catch (e) {
        if (i == NetworkConfig.pingRetryCount - 1) {
          return NetworkCheckResult.failed('Ping失败: ${e.message}');
        }
        // 等待一小段时间后重试
        await Future.delayed(const Duration(milliseconds: 500));
      } on TimeoutException {
        if (i == NetworkConfig.pingRetryCount - 1) {
          return NetworkCheckResult.failed('Ping超时');
        }
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        if (i == NetworkConfig.pingRetryCount - 1) {
          return NetworkCheckResult.failed('Ping错误: $e');
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return NetworkCheckResult.failed('Ping失败');
  }

  /// 监听网络连接变化
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// 获取当前网络连接状态
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }
}
