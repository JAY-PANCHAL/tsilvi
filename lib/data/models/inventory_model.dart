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
    super.isInCart,
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
      isInCart: json['isInCart'] == true,
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
      'isInCart': isInCart,
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
    final imagesRaw = json['images'];
    final list = <String>[];
    if (imagesRaw is List) {
      for (final entry in imagesRaw) {
        if (entry == null) continue;
        if (entry is String) {
          final trimmed = entry.trim();
          if (trimmed.isNotEmpty) list.add(trimmed);
          continue;
        }
        if (entry is Map) {
          final mapped = entry['url'] ??
              entry['imageUrl'] ??
              entry['image'] ??
              entry['src'] ??
              entry['path'];
          if (mapped != null) {
            final trimmed = mapped.toString().trim();
            if (trimmed.isNotEmpty) list.add(trimmed);
          }
          continue;
        }
        final fallback = entry.toString().trim();
        if (fallback.isNotEmpty) list.add(fallback);
      }
    } else if (imagesRaw is String) {
      final split = imagesRaw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      list.addAll(split);
    }
    if (list.isNotEmpty) return list;
    final imageUrl = json['imageUrl']?.toString() ??
        json['image']?.toString() ??
        json['productImage']?.toString() ??
        '';
    if (imageUrl.isNotEmpty) return [imageUrl];
    return [];
  }
}
