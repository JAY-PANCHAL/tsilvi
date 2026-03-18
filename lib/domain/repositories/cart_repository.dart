import '../entities/cart_item_entity.dart';
import '../entities/inventory_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> fetchCart();
  Future<CartItemEntity?> addToCart(InventoryEntity item, int quantity);
  Future<void> removeFromCart(String cartItemId);
}
