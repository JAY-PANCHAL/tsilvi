import 'cart_item_entity.dart';

class OrderEntity {
  final String id;
  final DateTime date;
  final double total;
  final List<CartItemEntity> items;

  OrderEntity({
    required this.id,
    required this.date,
    required this.total,
    required this.items,
  });
}
