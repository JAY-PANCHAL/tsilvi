import '../../domain/entities/cart_item_entity.dart';
import 'inventory_model.dart';

class CartModel extends CartItemEntity {
  CartModel({
    required InventoryModel item,
    required int quantity,
    String? cartItemId,
  }) : super(item: item, quantity: quantity, cartItemId: cartItemId);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final quantityRaw = json['quantity'] ?? json['qty'] ?? json['count'] ?? 1;
    final quantity = quantityRaw is num
        ? quantityRaw.toInt()
        : int.tryParse(quantityRaw.toString()) ?? 1;
    return CartModel(
      cartItemId: json['cartItemId']?.toString() ?? json['id']?.toString(),
      item: InventoryModel.fromJson(
          (json['item'] ?? json['product'] ?? json) as Map<String, dynamic>),
      quantity: quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'item': (item as InventoryModel).toJson(),
      'quantity': quantity,
    };
  }
}
