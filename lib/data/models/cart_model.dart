import '../../domain/entities/cart_item_entity.dart';
import 'inventory_model.dart';

class CartModel extends CartItemEntity {
  CartModel({
    required InventoryModel item,
    required int quantity,
    String? cartItemId,
  }) : super(item: item, quantity: quantity, cartItemId: cartItemId);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartItemId: json['cartItemId']?.toString() ?? json['id']?.toString(),
      item: InventoryModel.fromJson(
          (json['item'] ?? json['product'] ?? json) as Map<String, dynamic>),
      quantity: (json['quantity'] ?? 1) as int,
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
