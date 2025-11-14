/// Sunmi Customer API Service
/// 提供商米设备系统能力接口的 Flutter 封装
///
/// 主要功能模块：
/// - 设备信息模块
/// - 设备管理模块
/// - 网络管理模块
/// - 系统管理模块

import 'package:flutter/services.dart';

class SunmiCustomerApiService {
  static const MethodChannel _channel = MethodChannel(
    'com.holox.ailand_pos/sunmi_customer_api',
  );

  /// 单例模式
  static final SunmiCustomerApiService _instance =
      SunmiCustomerApiService._internal();
  factory SunmiCustomerApiService() => _instance;
  SunmiCustomerApiService._internal();

  /// 初始化服务
  /// 返回是否连接成功
  Future<bool> initialize() async {
    try {
      final bool? result = await _channel.invokeMethod('initialize');
      return result ?? false;
    } catch (e) {
      print('初始化 Sunmi Customer API 失败: $e');
      return false;
    }
  }

  /// 检查服务是否已连接
  Future<bool> isConnected() async {
    try {
      final bool? result = await _channel.invokeMethod('isConnected');
      return result ?? false;
    } catch (e) {
      print('检查连接状态失败: $e');
      return false;
    }
  }

  /// 检查 SunmiCustomerService 是否已安装
  /// 在初始化前调用此方法可以提前知道是否支持
  Future<bool> checkServiceInstalled() async {
    try {
      final bool? result = await _channel.invokeMethod('checkServiceInstalled');
      return result ?? false;
    } catch (e) {
      print('检查服务安装状态失败: $e');
      return false;
    }
  }

  /// ========== 网络管理模块 ==========

  /// 启用移动网络数据
  /// [slotIndex] SIM卡槽索引 (0 或 1)
  Future<bool> enableMobileNetwork({int slotIndex = 0}) async {
    try {
      await _channel.invokeMethod('enableMobileNetwork', {
        'slotIndex': slotIndex,
      });
      return true;
    } on PlatformException catch (e) {
      print('启用移动网络失败: ${e.message}');
      return false;
    } catch (e) {
      print('启用移动网络失败: $e');
      return false;
    }
  }

  /// 禁用移动网络数据
  /// [slotIndex] SIM卡槽索引 (0 或 1)
  Future<bool> disableMobileNetwork({int slotIndex = 0}) async {
    try {
      await _channel.invokeMethod('disableMobileNetwork', {
        'slotIndex': slotIndex,
      });
      return true;
    } on PlatformException catch (e) {
      print('禁用移动网络失败: ${e.message}');
      return false;
    } catch (e) {
      print('禁用移动网络失败: $e');
      return false;
    }
  }

  /// ========== 设备信息模块 ==========

  /// 获取设备型号
  Future<String?> getDeviceModel() async {
    try {
      final String? model = await _channel.invokeMethod('getDeviceModel');
      return model;
    } on PlatformException catch (e) {
      print('获取设备型号失败: ${e.message}');
      return null;
    } catch (e) {
      print('获取设备型号失败: $e');
      return null;
    }
  }

  /// 获取设备序列号
  Future<String?> getDeviceSerialNumber() async {
    try {
      final String? serialNumber = await _channel.invokeMethod(
        'getDeviceSerialNumber',
      );
      return serialNumber;
    } on PlatformException catch (e) {
      print('获取设备序列号失败: ${e.message}');
      return null;
    } catch (e) {
      print('获取设备序列号失败: $e');
      return null;
    }
  }

  /// 获取设备完整信息
  /// 返回包含以下字段的 Map:
  /// - model: 设备型号
  /// - serialNumber: 序列号
  /// - manufacturer: 制造商
  /// - brand: 品牌
  /// - androidVersion: Android 版本
  /// - sdkVersion: SDK 版本
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic>? info = await _channel.invokeMethod(
        'getDeviceInfo',
      );
      if (info == null) return null;

      return Map<String, dynamic>.from(info);
    } on PlatformException catch (e) {
      print('获取设备信息失败: ${e.message}');
      return null;
    } catch (e) {
      print('获取设备信息失败: $e');
      return null;
    }
  }

  /// 打印设备信息（用于调试）
  Future<void> printDeviceInfo() async {
    final info = await getDeviceInfo();
    if (info != null) {
      print('========== 商米设备信息 ==========');
      print('设备型号: ${info['model']}');
      print('序列号: ${info['serialNumber']}');
      print('制造商: ${info['manufacturer']}');
      print('品牌: ${info['brand']}');
      print('Android 版本: ${info['androidVersion']}');
      print('SDK 版本: ${info['sdkVersion']}');
      print('================================');
    } else {
      print('无法获取设备信息');
    }
  }
}

/// 设备信息数据类
class SunmiDeviceInfo {
  final String? model;
  final String? serialNumber;
  final String? manufacturer;
  final String? brand;
  final String? androidVersion;
  final String? sdkVersion;

  SunmiDeviceInfo({
    this.model,
    this.serialNumber,
    this.manufacturer,
    this.brand,
    this.androidVersion,
    this.sdkVersion,
  });

  factory SunmiDeviceInfo.fromMap(Map<String, dynamic> map) {
    return SunmiDeviceInfo(
      model: map['model'] as String?,
      serialNumber: map['serialNumber'] as String?,
      manufacturer: map['manufacturer'] as String?,
      brand: map['brand'] as String?,
      androidVersion: map['androidVersion'] as String?,
      sdkVersion: map['sdkVersion'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'serialNumber': serialNumber,
      'manufacturer': manufacturer,
      'brand': brand,
      'androidVersion': androidVersion,
      'sdkVersion': sdkVersion,
    };
  }

  @override
  String toString() {
    return 'SunmiDeviceInfo(model: $model, serialNumber: $serialNumber, '
        'manufacturer: $manufacturer, brand: $brand, '
        'androidVersion: $androidVersion, sdkVersion: $sdkVersion)';
  }
}
