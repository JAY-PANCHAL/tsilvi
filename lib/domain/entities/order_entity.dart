import 'cart_item_entity.dart';

class OrderEntity {
  final String id;
  final dynamic customerId;
  final String? sku;
  final double? silverPrice;
  final double? laborCostPerGm;
  final double? totalLaborCost;
  final double? totalNetWeight;
  final DateTime date;
  final double total;
  final List<CartItemEntity> items;

  OrderEntity({
    required this.id,
    this.customerId,
    this.sku,
    this.silverPrice,
    this.laborCostPerGm,
    this.totalLaborCost,
    this.totalNetWeight,
    required this.date,
    required this.total,
    required this.items,
  });
}
