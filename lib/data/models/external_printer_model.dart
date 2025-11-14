/// 外接打印机设备模型
/// 用于USB外接打印机的数据表示
class ExternalPrinterDevice {
  final String deviceId; // 设备ID
  final String deviceName; // 设备名称
  final String manufacturer; // 制造商
  final String productName; // 产品名称
  final int vendorId; // USB厂商ID
  final int productId; // USB产品ID
  final bool isConnected; // 是否已连接
  final String? serialNumber; // 序列号

  ExternalPrinterDevice({
    required this.deviceId,
    required this.deviceName,
    required this.manufacturer,
    required this.productName,
    required this.vendorId,
    required this.productId,
    required this.isConnected,
    this.serialNumber,
  });

  factory ExternalPrinterDevice.fromMap(Map<String, dynamic> map) {
    return ExternalPrinterDevice(
      deviceId: map['deviceId'] as String? ?? '',
      deviceName: map['deviceName'] as String? ?? 'Unknown Device',
      manufacturer: map['manufacturer'] as String? ?? 'Unknown',
      productName: map['productName'] as String? ?? 'Unknown',
      vendorId: map['vendorId'] as int? ?? 0,
      productId: map['productId'] as int? ?? 0,
      isConnected: map['isConnected'] as bool? ?? false,
      serialNumber: map['serialNumber'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'manufacturer': manufacturer,
      'productName': productName,
      'vendorId': vendorId,
      'productId': productId,
      'isConnected': isConnected,
      'serialNumber': serialNumber,
    };
  }

  @override
  String toString() {
    return 'ExternalPrinterDevice(id: $deviceId, name: $deviceName, '
        'manufacturer: $manufacturer, connected: $isConnected)';
  }

  /// 获取设备显示名称
  String get displayName {
    if (productName.isNotEmpty && productName != 'Unknown') {
      return productName;
    }
    return deviceName;
  }

  /// 获取USB标识符（厂商ID:产品ID）
  String get usbIdentifier {
    return '${vendorId.toRadixString(16).padLeft(4, '0')}:'
        '${productId.toRadixString(16).padLeft(4, '0')}';
  }
}

/// 外接打印机状态枚举
enum ExternalPrinterStatus {
  notConnected, // 未连接
  connected, // 已连接
  ready, // 就绪（已授权）
  printing, // 打印中
  error, // 错误
}

/// 外接打印机打印结果
class ExternalPrintResult {
  final bool success;
  final String message;
  final String? errorCode;

  ExternalPrintResult({
    required this.success,
    required this.message,
    this.errorCode,
  });

  factory ExternalPrintResult.fromMap(Map<String, dynamic> map) {
    return ExternalPrintResult(
      success: map['success'] as bool? ?? false,
      message: map['message'] as String? ?? '',
      errorCode: map['errorCode'] as String?,
    );
  }
}
