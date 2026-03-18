import 'package:get/get.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/inventory_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../core/utils/toast.dart';

class CartController extends GetxController {
  final CartRepository repository;

  CartController(this.repository);
  final items = <CartItemEntity>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    isLoading.value = true;
    final data = await repository.fetchCart();
    items.assignAll(data);
    isLoading.value = false;
  }

  Future<void> addItem(InventoryEntity item) async {
    final resolvedItemId =
        item.itemId ?? (item.id.isNotEmpty ? int.tryParse(item.id) : null);
    if (resolvedItemId == null) {
      showToast('Unable to add item', success: false);
      return;
    }
    final index = items.indexWhere((e) => e.item.id == item.id);
    final added = await repository.addToCart(item, 1);
    if (added == null) {
      showToast('Unable to add item', success: false);
      return;
    }
    if (index >= 0) {
      final current = items[index];
      items[index] = CartItemEntity(
        cartItemId: added.cartItemId ?? current.cartItemId,
        item: added.item,
        quantity: current.quantity + 1,
      );
    } else {
      items.add(CartItemEntity(
          cartItemId: added.cartItemId, item: added.item, quantity: 1));
    }
  }

  Future<void> removeItem(InventoryEntity item) async {
    final index = items.indexWhere((e) => e.item.id == item.id);
    if (index >= 0) {
      final existing = items[index];
      if (existing.cartItemId != null) {
        await repository.removeFromCart(existing.cartItemId!);
      }
      items.removeAt(index);
    }
  }

  Future<void> increment(InventoryEntity item) async {
    await addItem(item);
  }

  Future<void> decrement(InventoryEntity item) async {
    final index = items.indexWhere((e) => e.item.id == item.id);
    if (index >= 0) {
      final current = items[index];
      final newQty = current.quantity - 1;
      if (newQty <= 0) {
        await removeItem(item);
      } else {
        items[index] = CartItemEntity(item: current.item, quantity: newQty);
      }
    }
  }

  void setQuantity(InventoryEntity item, int quantity) {
    if (quantity <= 0) {
      removeItem(item);
      return;
    }
    final index = items.indexWhere((e) => e.item.id == item.id);
    if (index >= 0) {
      items[index] = CartItemEntity(item: item, quantity: quantity);
    } else {
      items.add(CartItemEntity(item: item, quantity: quantity));
    }
  }

  double get total {
    return items.fold(0, (sum, e) => sum + e.item.price * e.quantity);
  }

  int get totalItems {
    return items.fold(0, (sum, e) => sum + e.quantity);
  }

  void clear() {
    items.clear();
  }
}
