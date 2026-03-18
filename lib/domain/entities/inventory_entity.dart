class InventoryEntity {
  final String id;
  final int? itemId;
  final int? zohoBooksItemId;
  final String name;
  final String sku;
  final String description;
  final double price;
  final String currency;
  final String? color;
  final String? size;
  final bool isInCart;
  final List<String> images;

  InventoryEntity({
    required this.id,
    this.itemId,
    this.zohoBooksItemId,
    required this.name,
    required this.sku,
    required this.description,
    required this.price,
    this.currency = '',
    this.color,
    this.size,
    this.isInCart = false,
    required this.images,
  });
}
