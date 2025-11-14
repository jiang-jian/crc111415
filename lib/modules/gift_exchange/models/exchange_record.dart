/// ExchangeRecord
/// 兑换记录数据模型

class ExchangeRecord {
  final String id;
  final DateTime time;
  final String orderNumber;
  final String memberLevel;
  final String orderStatus;
  final String memberPhone;
  final String paymentMethod;
  final double amount;
  final String cashier;
  final String? remark;

  ExchangeRecord({
    required this.id,
    required this.time,
    required this.orderNumber,
    required this.memberLevel,
    required this.orderStatus,
    required this.memberPhone,
    required this.paymentMethod,
    required this.amount,
    required this.cashier,
    this.remark,
  });

  factory ExchangeRecord.fromJson(Map<String, dynamic> json) {
    return ExchangeRecord(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      orderNumber: json['orderNumber'] as String,
      memberLevel: json['memberLevel'] as String,
      orderStatus: json['orderStatus'] as String,
      memberPhone: json['memberPhone'] as String,
      paymentMethod: json['paymentMethod'] as String,
      amount: (json['amount'] as num).toDouble(),
      cashier: json['cashier'] as String,
      remark: json['remark'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'orderNumber': orderNumber,
      'memberLevel': memberLevel,
      'orderStatus': orderStatus,
      'memberPhone': memberPhone,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'cashier': cashier,
      'remark': remark,
    };
  }
}
