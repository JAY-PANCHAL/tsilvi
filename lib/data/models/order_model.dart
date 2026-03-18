import '../../domain/entities/order_entity.dart';
import 'cart_model.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    required super.date,
    required super.total,
    required super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['date'] ??
        json['createdOn'] ??
        json['createdAt'] ??
        json['orderDate'];
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
}
