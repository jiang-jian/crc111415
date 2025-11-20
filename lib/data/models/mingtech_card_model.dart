/// 明泰读卡器卡片数据模型
class MingtechCardData {
  /// 卡片UID（格式: AA:BB:CC:DD 或 AA:BB:CC:DD:EE:FF:GG）
  final String uid;

  /// 卡片类型（如: Mifare Classic 1K, Mifare Classic 4K）
  final String cardType;

  /// 检测时间
  final DateTime timestamp;

  MingtechCardData({
    required this.uid,
    required this.cardType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory MingtechCardData.fromMap(Map<dynamic, dynamic> map) {
    return MingtechCardData(
      uid: map['uid'] as String,
      cardType: map['cardType'] as String,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'cardType': cardType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MingtechCardData(uid: $uid, type: $cardType, time: $timestamp)';
  }
}

/// 读卡器事件类型
enum MingtechEventType {
  cardDetected,    // 检测到卡片
  authResult,      // 认证结果
  blockRead,       // 块读取完成
  deviceReady,     // 设备就绪
  deviceAttached,  // 设备插入
  deviceDetached,  // 设备拔出
  error,           // 错误
}

/// 读卡器事件
class MingtechEvent {
  /// 事件类型
  final MingtechEventType type;

  /// 事件数据
  final Map<String, dynamic> data;

  MingtechEvent({
    required this.type,
    required this.data,
  });

  factory MingtechEvent.fromMap(Map<dynamic, dynamic> map) {
    final eventStr = map['event'] as String;
    final type = _parseEventType(eventStr);

    return MingtechEvent(
      type: type,
      data: Map<String, dynamic>.from(map),
    );
  }

  static MingtechEventType _parseEventType(String eventStr) {
    switch (eventStr) {
      case 'card_detected':
        return MingtechEventType.cardDetected;
      case 'auth_result':
        return MingtechEventType.authResult;
      case 'block_read':
        return MingtechEventType.blockRead;
      case 'device_ready':
        return MingtechEventType.deviceReady;
      case 'device_attached':
        return MingtechEventType.deviceAttached;
      case 'device_detached':
        return MingtechEventType.deviceDetached;
      case 'error':
        return MingtechEventType.error;
      default:
        return MingtechEventType.error;
    }
  }

  /// 获取卡片数据（仅对card_detected事件有效）
  MingtechCardData? get cardData {
    if (type == MingtechEventType.cardDetected) {
      return MingtechCardData.fromMap(data);
    }
    return null;
  }

  /// 获取认证结果（仅对auth_result事件有效）
  bool? get authSuccess {
    if (type == MingtechEventType.authResult) {
      return data['success'] as bool?;
    }
    return null;
  }

  /// 获取块数据（仅对block_read事件有效）
  List<int>? get blockData {
    if (type == MingtechEventType.blockRead) {
      final dataList = data['data'] as List<dynamic>?;
      return dataList?.map((e) => e as int).toList();
    }
    return null;
  }

  /// 获取错误信息（仅对error事件有效）
  String? get errorMessage {
    if (type == MingtechEventType.error) {
      return data['message'] as String?;
    }
    return null;
  }

  /// 获取错误码（仅对error事件有效）
  String? get errorCode {
    if (type == MingtechEventType.error) {
      return data['code'] as String?;
    }
    return null;
  }

  @override
  String toString() {
    return 'MingtechEvent(type: $type, data: $data)';
  }
}

/// 设备信息
class MingtechDeviceInfo {
  final String deviceName;
  final int vendorId;
  final int productId;
  final String manufacturer;
  final String product;
  final String serialNumber;
  final int deviceId;
  final bool isConnected;

  MingtechDeviceInfo({
    required this.deviceName,
    required this.vendorId,
    required this.productId,
    required this.manufacturer,
    required this.product,
    required this.serialNumber,
    required this.deviceId,
    required this.isConnected,
  });

  factory MingtechDeviceInfo.fromMap(Map<dynamic, dynamic> map) {
    return MingtechDeviceInfo(
      deviceName: map['deviceName'] as String? ?? 'Unknown',
      vendorId: map['vendorId'] as int? ?? 0,
      productId: map['productId'] as int? ?? 0,
      manufacturer: map['manufacturer'] as String? ?? 'Unknown',
      product: map['product'] as String? ?? 'Unknown',
      serialNumber: map['serialNumber'] as String? ?? 'Unknown',
      deviceId: map['deviceId'] as int? ?? 0,
      isConnected: map['isConnected'] as bool? ?? false,
    );
  }

  String get usbId => '0x${vendorId.toRadixString(16).padLeft(4, '0').toUpperCase()}:0x${productId.toRadixString(16).padLeft(4, '0').toUpperCase()}';

  @override
  String toString() {
    return 'MingtechDeviceInfo(name: $deviceName, usb: $usbId, connected: $isConnected)';
  }
}
