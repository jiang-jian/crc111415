/// MemberInfoModel
/// 会员信息模型
/// 作者：AI 自动生成
/// 更新时间：2025-11-11

class MemberInfoModel {
  final String cardNumber;
  final String phoneNumber;
  final String? email;
  final String? watchId;
  final bool isMainCard;
  final String memberLevel;
  final CardAssetsData assets;
  final DateTime? expiryDate;
  final bool isLost;
  final String? lostReason;

  MemberInfoModel({
    required this.cardNumber,
    required this.phoneNumber,
    this.email,
    this.watchId,
    required this.isMainCard,
    required this.memberLevel,
    required this.assets,
    this.expiryDate,
    this.isLost = false,
    this.lostReason,
  });

  factory MemberInfoModel.fromJson(Map<String, dynamic> json) {
    return MemberInfoModel(
      cardNumber: json['cardNumber'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      watchId: json['watchId'],
      isMainCard: json['isMainCard'] ?? true,
      memberLevel: json['memberLevel'] ?? '普通会员',
      assets: CardAssetsData.fromJson(json['assets'] ?? {}),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      isLost: json['isLost'] ?? false,
      lostReason: json['lostReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'watchId': watchId,
      'isMainCard': isMainCard,
      'memberLevel': memberLevel,
      'assets': assets.toJson(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isLost': isLost,
      'lostReason': lostReason,
    };
  }

  static MemberInfoModel mockMainCard() {
    return MemberInfoModel(
      cardNumber: 'T000000001',
      phoneNumber: 'M000000001',
      email: null,
      watchId: null,
      isMainCard: true,
      memberLevel: '主卡',
      assets: CardAssetsData.mock(),
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      isLost: false,
    );
  }

  static MemberInfoModel mockSubCard() {
    return MemberInfoModel(
      cardNumber: 'SC000001',
      phoneNumber: 'M000000001',
      email: 'member@example.com',
      watchId: 'W12345678',
      isMainCard: false,
      memberLevel: '副卡',
      assets: CardAssetsData.mock(),
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      isLost: false,
    );
  }
}

class CardAssetsData {
  final double gameCoins;
  final double superCoins;
  final double lottery;
  final double doors;
  final double mysteryBoxes;
  final int memberCount;

  CardAssetsData({
    required this.gameCoins,
    required this.superCoins,
    required this.lottery,
    required this.doors,
    required this.mysteryBoxes,
    required this.memberCount,
  });

  factory CardAssetsData.fromJson(Map<String, dynamic> json) {
    return CardAssetsData(
      gameCoins: (json['gameCoins'] ?? 0).toDouble(),
      superCoins: (json['superCoins'] ?? 0).toDouble(),
      lottery: (json['lottery'] ?? 0).toDouble(),
      doors: (json['doors'] ?? 0).toDouble(),
      mysteryBoxes: (json['mysteryBoxes'] ?? 0).toDouble(),
      memberCount: json['memberCount'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameCoins': gameCoins,
      'superCoins': superCoins,
      'lottery': lottery,
      'doors': doors,
      'mysteryBoxes': mysteryBoxes,
      'memberCount': memberCount,
    };
  }

  static CardAssetsData mock() {
    return CardAssetsData(
      gameCoins: 1000,
      superCoins: 150789,
      lottery: 10,
      doors: 5,
      mysteryBoxes: 15,
      memberCount: 1,
    );
  }
}
