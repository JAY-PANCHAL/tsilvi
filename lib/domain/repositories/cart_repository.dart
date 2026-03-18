import '../entities/cart_item_entity.dart';
import '../entities/cart_summary_entity.dart';
import '../entities/inventory_entity.dart';

abstract class CartRepository {
  Future<CartSummaryEntity> fetchCart();
  Future<CartItemEntity?> addToCart(InventoryEntity item, int quantity);
  Future<void> removeFromCart(String cartItemId);
}
