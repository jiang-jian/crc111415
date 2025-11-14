/// 外接读卡器设备模型
/// 用于USB外接读卡器的数据表示
class ExternalCardReaderDevice {
  final String deviceId; // 设备ID
  final String deviceName; // 设备名称（友好名称）
  final String manufacturer; // 制造商
  final String productName; // 产品名称
  final String? model; // 型号
  final String? specifications; // 规格
  final int vendorId; // USB厂商ID
  final int productId; // USB产品ID
  final bool isConnected; // 是否已连接
  final String? serialNumber; // 序列号
  final String? usbPath; // USB路径（用于调试）

  ExternalCardReaderDevice({
    required this.deviceId,
    required this.deviceName,
    required this.manufacturer,
    required this.productName,
    this.model,
    this.specifications,
    required this.vendorId,
    required this.productId,
    required this.isConnected,
    this.serialNumber,
    this.usbPath,
  });

  factory ExternalCardReaderDevice.fromMap(Map<String, dynamic> map) {
    return ExternalCardReaderDevice(
      deviceId: map['deviceId'] as String? ?? '',
      deviceName: map['deviceName'] as String? ?? 'Unknown Device',
      manufacturer: map['manufacturer'] as String? ?? 'Unknown',
      productName: map['productName'] as String? ?? 'Unknown',
      model: map['model'] as String?,
      specifications: map['specifications'] as String?,
      vendorId: map['vendorId'] as int? ?? 0,
      productId: map['productId'] as int? ?? 0,
      isConnected: map['isConnected'] as bool? ?? false,
      serialNumber: map['serialNumber'] as String?,
      usbPath: map['usbPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'manufacturer': manufacturer,
      'productName': productName,
      'model': model,
      'specifications': specifications,
      'vendorId': vendorId,
      'productId': productId,
      'isConnected': isConnected,
      'serialNumber': serialNumber,
      'usbPath': usbPath,
    };
  }

  @override
  String toString() {
    return 'ExternalCardReaderDevice(id: $deviceId, name: $deviceName, '
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

/// 外接读卡器状态枚举
enum ExternalCardReaderStatus {
  notConnected, // 未连接
  connecting, // 连接中（请求权限中）
  connected, // 已连接（可用）
  reading, // 读卡中
  error, // 错误
}

/// 读卡结果模型
class CardReadResult {
  final bool success; // 是否成功
  final String message; // 消息
  final Map<String, dynamic>? cardData; // 卡片数据
  final String? errorCode; // 错误码

  CardReadResult({
    required this.success,
    required this.message,
    this.cardData,
    this.errorCode,
  });

  factory CardReadResult.fromMap(Map<String, dynamic> map) {
    return CardReadResult(
      success: map['success'] as bool? ?? false,
      message: map['message'] as String? ?? '',
      cardData: map['cardData'] as Map<String, dynamic>?,
      errorCode: map['errorCode'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'cardData': cardData,
      'errorCode': errorCode,
    };
  }
}
