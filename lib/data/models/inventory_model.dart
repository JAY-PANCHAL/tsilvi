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
    super.laborCost,
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
      laborCost: _toNullableDouble(pickFirst([
        json['laborCost'],
        json['labourCost'],
        json['labor_cost'],
        json['labour_cost'],
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
      'laborCost': laborCost,
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

    String? normalizeUrl(dynamic raw) {
      if (raw == null) return null;
      final value = raw.toString().trim();
      if (value.isEmpty) return null;
      // Some backend URLs contain spaces (e.g. "... (1).jpg") which must be
      // percent-encoded for consistent loading across Android versions.
      if (value.contains(' ')) {
        return Uri.encodeFull(value);
      }
      return value;
    }

    void addRawImages(dynamic raw) {
      if (raw is List) {
        for (final entry in raw) {
          if (entry == null) continue;
          if (entry is String) {
            final parts = entry.split(',');
            for (final part in parts) {
              final normalized = normalizeUrl(part);
              if (normalized != null) list.add(normalized);
            }
            continue;
          }
          if (entry is Map) {
            final mapped = entry['url'] ??
                entry['imageUrl'] ??
                entry['image'] ??
                entry['src'] ??
                entry['path'] ??
                entry['webMedia'] ??
                entry['mobMedia'];
            if (mapped != null) {
              addRawImages(mapped);
            } else {
              final normalized = normalizeUrl(entry.toString());
              if (normalized != null) list.add(normalized);
            }
            continue;
          }
          final normalized = normalizeUrl(entry);
          if (normalized != null) list.add(normalized);
        }
        return;
      }

      if (raw is String) {
        final split =
            raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final entry in split) {
          final normalized = normalizeUrl(entry);
          if (normalized != null) list.add(normalized);
        }
      }
    }

    addRawImages(json['images']);
    addRawImages(json['imageMulti']);
    addRawImages(json['imageUrlMulti']);
    addRawImages(json['imagemulti']);
    addRawImages(json['productMedias']);
    addRawImages(json['productMedia']);

    if (list.isNotEmpty) {
      return list.toSet().toList();
    }

    final imageUrl = normalizeUrl(json['imageUrl']) ??
        normalizeUrl(json['image']) ??
        normalizeUrl(json['productImage']);
    if (imageUrl != null) return [imageUrl];
    return [];
  }
}
