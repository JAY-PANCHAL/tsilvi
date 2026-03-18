import '../../domain/entities/inventory_entity.dart';

class InventoryModel extends InventoryEntity {
  InventoryModel({
    required super.id,
    super.itemId,
    super.zohoBooksItemId,
    required super.name,
    required super.sku,
    required super.description,
    required super.price,
    super.currency,
    super.color,
    super.size,
    required super.images,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    final resolvedId =
        (json['id'] ?? json['_id'] ?? json['itemId'] ?? json['code'] ?? '');
    final resolvedItemId = _toInt(json['itemId']) ??
        _toInt(json['productId']) ??
        _toInt(json['code']) ??
        _toInt(resolvedId);
    return InventoryModel(
      id: resolvedId.toString(),
      itemId: resolvedItemId,
      zohoBooksItemId: _toInt(json['zohoBooksItemId']),
      name: (json['name'] ?? json['title'] ?? json['productName'] ?? 'Item')
          .toString(),
      sku: (json['sku'] ?? json['code'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(
          json['price'] ?? json['unitPrice'] ?? json['finalUnitPrice'] ?? 0),
      currency: (json['currency'] ?? json['currencyCode'] ?? '').toString(),
      color: json['color']?.toString(),
      size: json['size']?.toString(),
      images: _extractImages(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'zohoBooksItemId': zohoBooksItemId,
      'name': name,
      'sku': sku,
      'description': description,
      'price': price,
      'currency': currency,
      'color': color,
      'size': size,
      'images': images,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _extractImages(Map<String, dynamic> json) {
    final list = (json['images'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];
    if (list.isNotEmpty) return list;
    final imageUrl = json['imageUrl']?.toString() ??
        json['image']?.toString() ??
        json['productImage']?.toString() ??
        '';
    if (imageUrl.isNotEmpty) return [imageUrl];
    return [];
  }
}
