/// CardAssetsModel
/// 会员卡资产模型

class CardAssetsModel {
  final double gameCoins;
  final double superCoins;
  final double lottery;
  final double giftVoucher;
  final double cashVoucher;
  final double memberBalance;
  final double depositCoins;
  final double depositTickets;
  final double rechargeAmount;
  final DateTime? expiryDate;

  CardAssetsModel({
    required this.gameCoins,
    required this.superCoins,
    required this.lottery,
    required this.giftVoucher,
    required this.cashVoucher,
    required this.memberBalance,
    required this.depositCoins,
    required this.depositTickets,
    required this.rechargeAmount,
    this.expiryDate,
  });

  factory CardAssetsModel.fromJson(Map<String, dynamic> json) {
    return CardAssetsModel(
      gameCoins: (json['gameCoins'] ?? 0).toDouble(),
      superCoins: (json['superCoins'] ?? 0).toDouble(),
      lottery: (json['lottery'] ?? 0).toDouble(),
      giftVoucher: (json['giftVoucher'] ?? 0).toDouble(),
      cashVoucher: (json['cashVoucher'] ?? 0).toDouble(),
      memberBalance: (json['memberBalance'] ?? 0).toDouble(),
      depositCoins: (json['depositCoins'] ?? 0).toDouble(),
      depositTickets: (json['depositTickets'] ?? 0).toDouble(),
      rechargeAmount: (json['rechargeAmount'] ?? 0).toDouble(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameCoins': gameCoins,
      'superCoins': superCoins,
      'lottery': lottery,
      'giftVoucher': giftVoucher,
      'cashVoucher': cashVoucher,
      'memberBalance': memberBalance,
      'depositCoins': depositCoins,
      'depositTickets': depositTickets,
      'rechargeAmount': rechargeAmount,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  static CardAssetsModel mock() {
    return CardAssetsModel(
      gameCoins: 1250,
      superCoins: 500,
      lottery: 88,
      giftVoucher: 200,
      cashVoucher: 150,
      memberBalance: 3680,
      depositCoins: 300,
      depositTickets: 45,
      rechargeAmount: 5000,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    );
  }
}
