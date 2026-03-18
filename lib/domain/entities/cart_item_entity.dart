import 'inventory_entity.dart';

class CartItemEntity {
  final String? cartItemId;
  final InventoryEntity item;
  final int quantity;

  CartItemEntity({
    this.cartItemId,
    required this.item,
    required this.quantity,
  });
}
