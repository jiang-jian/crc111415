import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/mingtech_card_model.dart';

/// 明泰MT3-URF1-R333读卡器服务
/// 
/// 功能：
/// - 设备初始化与权限管理
/// - 自动寻卡与事件监听
/// - M1卡扇区认证
/// - M1卡块数据读取
class MingtechReaderService extends GetxService {
  static const MethodChannel _methodChannel = MethodChannel('mingtech_reader/method');
  static const EventChannel _eventChannel = EventChannel('mingtech_reader/event');

  // 设备状态
  final Rx<MingtechDeviceInfo?> deviceInfo = Rx<MingtechDeviceInfo?>(null);
  final isInitialized = false.obs;
  final isAutoPolling = false.obs;

  // 当前卡片
  final Rx<MingtechCardData?> currentCard = Rx<MingtechCardData?>(null);

  // 最近的事件
  final recentEvents = <MingtechEvent>[].obs;

  // 错误信息
  final Rx<String?> lastError = Rx<String?>(null);

  // 事件流订阅
  StreamSubscription<dynamic>? _eventSubscription;

  /// 初始化服务
  Future<MingtechReaderService> init() async {
    _addLog('初始化明泰读卡器服务');

    if (kIsWeb) {
      _addLog('Web平台不支持USB设备');
      return this;
    }

    try {
      // 监听事件流
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        _handleEvent,
        onError: (error) {
          _addLog('事件流错误: $error');
          lastError.value = '事件流错误: $error';
        },
      );

      _addLog('事件监听已启动');
      return this;
    } catch (e, stackTrace) {
      _addLog('初始化失败: $e');
      if (kDebugMode) {
        print('[MingtechReader] 初始化失败: $e');
        print(stackTrace);
      }
      return this;
    }
  }

  /// 初始化读卡器设备
  Future<bool> initializeDevice() async {
    try {
      _addLog('========== 初始化读卡器设备 ==========');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('init');
      if (result == null) {
        _addLog('初始化失败: 返回空结果');
        lastError.value = '初始化失败';
        return false;
      }

      final success = result['success'] as bool? ?? false;
      final message = result['message'] as String? ?? '未知结果';

      _addLog('初始化结果: ${success ? "成功" : "失败"} - $message');

      if (success) {
        isInitialized.value = true;
        // 获取设备信息
        await refreshDeviceInfo();
      } else {
        lastError.value = message;
      }

      return success;
    } catch (e, stackTrace) {
      _addLog('初始化异常: $e');
      lastError.value = '初始化异常: $e';
      if (kDebugMode) {
        print('[MingtechReader] 初始化异常: $e');
        print(stackTrace);
      }
      return false;
    }
  }

  /// 刷新设备信息
  Future<void> refreshDeviceInfo() async {
    try {
      final info = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getDeviceInfo');
      if (info != null && !info.containsKey('error')) {
        deviceInfo.value = MingtechDeviceInfo.fromMap(info);
        _addLog('设备信息已更新: ${deviceInfo.value}');
      }
    } catch (e) {
      _addLog('获取设备信息失败: $e');
    }
  }

  /// 启动自动寻卡
  Future<bool> startAutoPolling() async {
    if (!isInitialized.value) {
      _addLog('启动自动寻卡失败: 设备未初始化');
      return false;
    }

    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('startAutoPolling');
      final success = result?['success'] as bool? ?? false;

      if (success) {
        isAutoPolling.value = true;
        _addLog('自动寻卡已启动');
      }

      return success;
    } catch (e) {
      _addLog('启动自动寻卡异常: $e');
      return false;
    }
  }

  /// 停止自动寻卡
  Future<bool> stopAutoPolling() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('stopAutoPolling');
      final success = result?['success'] as bool? ?? false;

      if (success) {
        isAutoPolling.value = false;
        _addLog('自动寻卡已停止');
      }

      return success;
    } catch (e) {
      _addLog('停止自动寻卡异常: $e');
      return false;
    }
  }

  /// 认证扇区
  /// 
  /// @param sector 扇区号（0-15）
  /// @param key 密钥（6字节）
  /// @param useKeyA true=使用KeyA，false=使用KeyB
  Future<bool> authSector(int sector, List<int> key, {bool useKeyA = true}) async {
    if (!isInitialized.value) {
      _addLog('认证扇区失败: 设备未初始化');
      return false;
    }

    if (key.length != 6) {
      _addLog('认证扇区失败: 密钥长度必须为6字节');
      return false;
    }

    try {
      _addLog('认证扇区 $sector，密钥类型: ${useKeyA ? "KeyA" : "KeyB"}');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'authSector',
        {
          'sector': sector,
          'key': key,
          'keyA': useKeyA,
        },
      );

      final success = result?['success'] as bool? ?? false;
      _addLog('认证结果: ${success ? "成功" : "失败"}');

      return success;
    } catch (e) {
      _addLog('认证扇区异常: $e');
      return false;
    }
  }

  /// 读取块数据
  /// 
  /// @param block 块号（0-63 for 1K, 0-255 for 4K）
  /// @return 块数据（16字节），失败返回null
  Future<List<int>?> readBlock(int block) async {
    if (!isInitialized.value) {
      _addLog('读取块失败: 设备未初始化');
      return null;
    }

    try {
      _addLog('读取块 $block');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'readBlock',
        {'block': block},
      );

      if (result == null) {
        _addLog('读取块失败: 返回空结果');
        return null;
      }

      final success = result['success'] as bool? ?? false;
      if (!success) {
        final message = result['message'] as String? ?? '未知错误';
        _addLog('读取块失败: $message');
        return null;
      }

      final dataList = result['data'] as List<dynamic>?;
      if (dataList == null || dataList.length != 16) {
        _addLog('读取块失败: 数据格式错误');
        return null;
      }

      final data = dataList.map((e) => e as int).toList();
      _addLog('读取块成功: ${data.map((b) => b.toRadixString(16).padLeft(2, "0").toUpperCase()).join(" ")}');

      return data;
    } catch (e) {
      _addLog('读取块异常: $e');
      return null;
    }
  }

  /// 处理事件
  void _handleEvent(dynamic eventData) {
    try {
      if (eventData is! Map) {
        _addLog('无效的事件数据类型: ${eventData.runtimeType}');
        return;
      }

      final event = MingtechEvent.fromMap(eventData);
      _addLog('收到事件: ${event.type} - ${event.data}');

      // 保存到最近事件列表
      recentEvents.insert(0, event);
      if (recentEvents.length > 50) {
        recentEvents.removeRange(50, recentEvents.length);
      }

      // 根据事件类型处理
      switch (event.type) {
        case MingtechEventType.cardDetected:
          currentCard.value = event.cardData;
          lastError.value = null;
          _addLog('检测到卡片: ${event.cardData?.uid}');
          break;

        case MingtechEventType.deviceReady:
          isInitialized.value = true;
          _addLog('设备已就绪');
          break;

        case MingtechEventType.deviceDetached:
          isInitialized.value = false;
          isAutoPolling.value = false;
          currentCard.value = null;
          deviceInfo.value = null;
          _addLog('设备已断开');
          break;

        case MingtechEventType.error:
          final errorMsg = event.errorMessage ?? '未知错误';
          lastError.value = errorMsg;
          _addLog('错误: $errorMsg');
          break;

        default:
          break;
      }
    } catch (e, stackTrace) {
      _addLog('处理事件异常: $e');
      if (kDebugMode) {
        print('[MingtechReader] 处理事件异常: $e');
        print(stackTrace);
      }
    }
  }

  /// 清除当前卡片
  void clearCard() {
    currentCard.value = null;
    _addLog('已清除当前卡片');
  }

  /// 清除错误信息
  void clearError() {
    lastError.value = null;
  }

  /// 添加日志
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().split('.').first;
    if (kDebugMode) {
      print('[MingtechReader][$timestamp] $message');
    }
  }

  @override
  void onClose() {
    _addLog('服务关闭');
    _eventSubscription?.cancel();
    stopAutoPolling();
    super.onClose();
  }
}
