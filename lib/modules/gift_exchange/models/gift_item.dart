/// GiftItem
/// 礼品商品模型

class GiftItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isSoldOut;
  final String? imageUrl;
  final int? stock;
  final String? specification;

  GiftItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isSoldOut = false,
    this.imageUrl,
    this.stock,
    this.specification,
  });
}
