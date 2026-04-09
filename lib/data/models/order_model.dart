import '../../domain/entities/order_entity.dart';
import 'cart_model.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    super.customerId,
    super.sku,
    super.silverPrice,
    super.laborCostPerGm,
    super.totalLaborCost,
    super.totalNetWeight,
    required super.date,
    required super.total,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['date'] ??
        json['createdOn'] ??
        json['createdAt'] ??
        json['orderDate'] ??
        json['placedOn'];
    final totalRaw =
        json['total'] ?? json['grandTotal'] ?? json['totalAmount'] ?? 0;
    final itemsRaw = json['items'] ?? json['orderItems'] ?? json['products'];
    List<Map<String, dynamic>> parsedItems = [];
    if (itemsRaw is List) {
      parsedItems = itemsRaw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else if (itemsRaw is Map) {
      final nested =
          itemsRaw['items'] ?? itemsRaw['products'] ?? itemsRaw['orderItems'];
      if (nested is List) {
        parsedItems = nested
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return OrderModel(
      id: (json['id'] ?? json['orderId'] ?? '').toString(),
      customerId: json['customerId'] ?? json['customer_id'] ?? json['userId'],
      sku: _toNullableString(
        json['sku'] ??
            json['itemSku'] ??
            json['productSku'] ??
            _firstSku(parsedItems) ??
            (json['data'] is Map<String, dynamic> ? json['data']['sku'] : null),
      ),
      silverPrice: _toNullableDouble(
        // Prefer total/order-level silver values first.
        json['totalSilverPrice'] ??
            json['totalSilverRate'] ??
            json['silverRate'] ??
            json['silver_rate'] ??
            json['silverPrice'] ??
            json['silverprice'] ??
            (json['data'] is Map<String, dynamic>
                ? (json['data']['silverPrice'] ??
                    json['data']['silverRate'] ??
                    json['data']['totalSilverPrice'] ??
                    json['data']['totalSilverRate'])
                : null),
      ),
      laborCostPerGm: _toNullableDouble(
        json['laborCostPerGm'] ??
            json['labourCostPerGm'] ??
            json['laborCost'] ??
            json['labourCost'] ??
            json['totalLaborCostPerGm'] ??
            json['totalLabourCostPerGm'] ??
            (json['data'] is Map<String, dynamic>
                ? (json['data']['laborCostPerGm'] ??
                    json['data']['labourCostPerGm'] ??
                    json['data']['totalLaborCostPerGm'] ??
                    json['data']['totalLabourCostPerGm'])
                : null),
      ),
      totalLaborCost: _toNullableDouble(
        json['totalLaborCost'] ??
            json['totalLabourCost'] ??
            json['totalLabourCharges'] ??
            (json['data'] is Map<String, dynamic>
                ? (json['data']['totalLaborCost'] ??
                    json['data']['totalLabourCost'] ??
                    json['data']['totalLabourCharges'])
                : null),
      ),
      totalNetWeight: _toNullableDouble(
        json['totalNetWeight'] ??
            json['netWeight'] ??
            json['totalNetWt'] ??
            (json['data'] is Map<String, dynamic>
                ? (json['data']['totalNetWeight'] ?? json['data']['netWeight'])
                : null),
      ),
      date: _parseDate(dateRaw),
      total: (totalRaw is num ? totalRaw : 0).toDouble(),
      items: parsedItems.map((e) => CartModel.fromJson(e)).toList(),
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is int) {
      if (raw > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(raw);
      }
      if (raw > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      }
    }
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (customerId != null) 'customerId': customerId,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
      if (silverPrice != null) 'silverPrice': silverPrice,
      if (laborCostPerGm != null) 'laborCostPerGm': laborCostPerGm,
      if (totalLaborCost != null) 'totalLaborCost': totalLaborCost,
      if (totalNetWeight != null) 'totalNetWeight': totalNetWeight,
      'date': date.toIso8601String(),
      'total': total,
      'items': items
          .map((e) => e is CartModel
              ? e.toJson()
              : {
                  'itemId': e.item.itemId,
                  'quantity': e.quantity,
                  'unitPrice': e.item.price,
                })
          .toList(),
    };
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final v = value.trim();
      if (v.isEmpty || v.toLowerCase() == 'null') return null;
      return double.tryParse(v);
    }
    return null;
  }

  static String? _firstSku(List<Map<String, dynamic>> items) {
    for (final item in items) {
      final sku = _toNullableString(item['sku'] ?? item['code']);
      if (sku != null) return sku;
    }
    return null;
  }
}
