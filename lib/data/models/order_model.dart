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
    return OrderModel(
      id: (json['id'] ?? json['orderId'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      total: ((json['total'] ?? 0) as num).toDouble(),
      items: (json['items'] as List?)
              ?.map((e) => CartModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
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
