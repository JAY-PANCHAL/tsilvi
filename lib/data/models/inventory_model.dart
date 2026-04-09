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
    super.netWeight,
    super.laborCostPerGm,
    super.silverPrice,
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

    // Backend field names have not been consistent across list/detail endpoints.
    // Be permissive here so UI can show Net Wt / Labour rate whenever present.
    dynamic pickFirst(Iterable<dynamic> candidates) {
      for (final v in candidates) {
        if (v == null) continue;
        if (v is String && v.trim().isEmpty) continue;
        return v;
      }
      return null;
    }

    return InventoryModel(
      id: resolvedId.toString(),
      itemId: resolvedItemId,
      zohoBooksItemId: _toInt(json['zohoBooksItemId']),
      name: (json['name'] ?? json['title'] ?? json['productName'] ?? 'Item')
          .toString(),
      sku: (json['sku'] ?? json['productSku'] ?? json['itemSku'] ?? '')
          .toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(
          json['price'] ?? json['unitPrice'] ?? json['finalUnitPrice'] ?? 0),
      currency: (json['currency'] ?? json['currencyCode'] ?? '').toString(),
      color: json['color']?.toString(),
      size: json['size']?.toString(),
      netWeight: _toNullableDouble(pickFirst([
        json['netWeight'],
        json['net_weight'],
        json['netweight'],
        json['netWt'],
        json['net_wt'],
      ])),
      laborCostPerGm: _toNullableDouble(pickFirst([
        json['laborCostPerGm'],
        json['labourCostPerGm'],
        json['laborRate'],
        json['labourRate'],
        json['laborRatePerGm'],
        json['labourRatePerGm'],
      ])),
      silverPrice: _toNullableDouble(pickFirst([
        json['silverPrice'],
        json['silverRate'],
        json['silver_rate'],
      ])),
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
      'netWeight': netWeight,
      'laborCostPerGm': laborCostPerGm,
      'silverPrice': silverPrice,
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

  static double? _toNullableDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _extractImages(Map<String, dynamic> json) {
    final list = <String>[];

    void addRawImages(dynamic raw) {
      if (raw is List) {
        for (final entry in raw) {
          if (entry == null) continue;
          if (entry is String) {
            final parts = entry.split(',');
            for (final part in parts) {
              final trimmed = part.trim();
              if (trimmed.isNotEmpty) list.add(trimmed);
            }
            continue;
          }
          if (entry is Map) {
            final mapped = entry['url'] ??
                entry['imageUrl'] ??
                entry['image'] ??
                entry['src'] ??
                entry['path'];
            if (mapped != null) addRawImages(mapped);
            continue;
          }
          final fallback = entry.toString().trim();
          if (fallback.isNotEmpty) list.add(fallback);
        }
        return;
      }

      if (raw is String) {
        final split =
            raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        list.addAll(split);
      }
    }

    addRawImages(json['images']);
    addRawImages(json['imageMulti']);
    addRawImages(json['imageUrlMulti']);
    addRawImages(json['imagemulti']);

    if (list.isNotEmpty) {
      return list.toSet().toList();
    }

    final imageUrl = json['imageUrl']?.toString() ??
        json['image']?.toString() ??
        json['productImage']?.toString() ??
        '';
    if (imageUrl.isNotEmpty) return [imageUrl];
    return [];
  }
}
