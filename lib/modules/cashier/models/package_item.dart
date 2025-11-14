/// PackageItem
/// 充值套餐模型

class PackageItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isSoldOut;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String? imageUrl;
  final int? stock;
  final String? specification;

  PackageItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isSoldOut = false,
    this.validFrom,
    this.validTo,
    this.imageUrl,
    this.stock,
    this.specification,
  });
}
