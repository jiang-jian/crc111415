/// 小票模板类型枚举
enum ReceiptTemplateType {
  custody('custody', '托管小票'),
  payment('payment', '支付小票'),
  exchange('exchange', '兑换小票');

  final String code;
  final String displayName;

  const ReceiptTemplateType(this.code, this.displayName);

  static ReceiptTemplateType fromCode(String code) {
    return ReceiptTemplateType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => ReceiptTemplateType.custody,
    );
  }
}

/// 小票模板模型
class ReceiptTemplate {
  final String id;
  final ReceiptTemplateType type;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  ReceiptTemplate({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory ReceiptTemplate.fromMap(Map<String, dynamic> map) {
    return ReceiptTemplate(
      id: map['id'] as String? ?? '',
      type: ReceiptTemplateType.fromCode(map['type'] as String? ?? 'custody'),
      content: map['content'] as String? ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.code,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  ReceiptTemplate copyWith({
    String? id,
    ReceiptTemplateType? type,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ReceiptTemplate(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// 商品项模型（用于支付小票）
class ProductItem {
  final String name; // 商品名称
  final double unitPrice; // 单价
  final int quantity; // 数量
  final double totalPrice; // 总价

  const ProductItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory ProductItem.fromMap(Map<String, dynamic> map) {
    return ProductItem(
      name: map['name'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }
}

/// 小票打印数据模型
class ReceiptPrintData {
  final String storeName; // 门店名称
  final String operatorName; // 操作员姓名
  final String storageId; // 存币单号
  final String memberId; // 会员编号
  final String memberName; // 会员姓名
  final String telephone; // 电话
  final int numberTickets; // 彩票数量
  final String storeAddress; // 门店地址
  final DateTime operationTime; // 操作时间
  final DateTime printTime; // 打印时间
  final String? barcode; // 条形码数据

  // 支付小票专用字段
  final List<ProductItem>? products; // 商品列表
  final double? subtotal; // 小计金额
  final double? discount; // 优惠金额
  final double? totalAmount; // 应付金额
  final double? paidAmount; // 实付金额
  final double? changeAmount; // 找零金额
  final String? qrcodeData; // 二维码数据

  ReceiptPrintData({
    required this.storeName,
    required this.operatorName,
    required this.storageId,
    required this.memberId,
    required this.memberName,
    required this.telephone,
    required this.numberTickets,
    required this.storeAddress,
    required this.operationTime,
    required this.printTime,
    this.barcode,
    // 支付小票专用字段（可选）
    this.products,
    this.subtotal,
    this.discount,
    this.totalAmount,
    this.paidAmount,
    this.changeAmount,
    this.qrcodeData,
  });

  factory ReceiptPrintData.fromMap(Map<String, dynamic> map) {
    return ReceiptPrintData(
      storeName: map['storeName'] as String? ?? '',
      operatorName: map['operatorName'] as String? ?? '',
      storageId: map['storageId'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? '',
      telephone: map['telephone'] as String? ?? '',
      numberTickets: map['numberTickets'] as int? ?? 0,
      storeAddress: map['storeAddress'] as String? ?? '',
      operationTime: DateTime.parse(
        map['operationTime'] as String? ?? DateTime.now().toIso8601String(),
      ),
      printTime: DateTime.parse(
        map['printTime'] as String? ?? DateTime.now().toIso8601String(),
      ),
      barcode: map['barcode'] as String?,
      // 支付小票专用字段
      products: (map['products'] as List<dynamic>?)
          ?.map((item) => ProductItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble(),
      discount: (map['discount'] as num?)?.toDouble(),
      totalAmount: (map['totalAmount'] as num?)?.toDouble(),
      paidAmount: (map['paidAmount'] as num?)?.toDouble(),
      changeAmount: (map['changeAmount'] as num?)?.toDouble(),
      qrcodeData: map['qrcodeData'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'operatorName': operatorName,
      'storageId': storageId,
      'memberId': memberId,
      'memberName': memberName,
      'telephone': telephone,
      'numberTickets': numberTickets,
      'storeAddress': storeAddress,
      'operationTime': operationTime.toIso8601String(),
      'printTime': printTime.toIso8601String(),
      'barcode': barcode,
      // 支付小票专用字段
      'products': products?.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
      'qrcodeData': qrcodeData,
    };
  }

  /// 创建模拟数据（用于测试）
  factory ReceiptPrintData.mock() {
    return ReceiptPrintData(
      storeName: 'HoloX超乐场-Dubai mall',
      operatorName: '美丽',
      storageId: 'CG202501100001',
      memberId: 'M123456789',
      memberName: '张三',
      telephone: '138-1234-5678',
      numberTickets: 150,
      storeAddress: 'Dubai Mall 2F',
      operationTime: DateTime.now(),
      printTime: DateTime.now(),
      barcode: 'CG202501100001',
      // 支付小票示例数据
      products: [
        const ProductItem(
          name: '100元100枚游戏币',
          unitPrice: 100.00,
          quantity: 2,
          totalPrice: 200.00,
        ),
        const ProductItem(
          name: '200元200枚游戏币+50枚超级币',
          unitPrice: 200.00,
          quantity: 1,
          totalPrice: 200.00,
        ),
        const ProductItem(
          name: '法式小面包',
          unitPrice: 20.00,
          quantity: 1,
          totalPrice: 20.00,
        ),
        const ProductItem(
          name: '可乐',
          unitPrice: 3.00,
          quantity: 2,
          totalPrice: 6.00,
        ),
        const ProductItem(
          name: '署片',
          unitPrice: 6.00,
          quantity: 1,
          totalPrice: 6.00,
        ),
      ],
      subtotal: 432.00,
      discount: 20.00,
      totalAmount: 402.00,
      paidAmount: 402.00,
      changeAmount: 0.00,
      qrcodeData: 'https://invoice.holox.com/01339483945069',
    );
  }
}
