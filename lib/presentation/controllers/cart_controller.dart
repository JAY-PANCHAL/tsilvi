import 'package:get/get.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/inventory_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../core/utils/toast.dart';
import 'users_controller.dart';

class CartController extends GetxController {
  final CartRepository repository;

  CartController(this.repository);
  final items = <CartItemEntity>[].obs;
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final subtotal = 0.0.obs;
  final productDiscountTotal = 0.0.obs;
  final couponDiscount = 0.0.obs;
  final taxAmount = 0.0.obs;
  final shippingAmount = 0.0.obs;
  final silverPrice = 0.0.obs;
  final totalLaborCost = 0.0.obs;
  final totalNetWeight = 0.0.obs;
  final grandTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchCart() async {
    if (!Get.find<UsersController>().hasSelectedUser) {
      clear();
      return;
    }
    isLoading.value = true;
    try {
      final data = await repository.fetchCart();
      items.assignAll(data.items);
      subtotal.value = data.subtotal;
      productDiscountTotal.value = data.productDiscountTotal;
      couponDiscount.value = data.couponDiscount;
      taxAmount.value = data.taxAmount;
      shippingAmount.value = data.shippingAmount;
      silverPrice.value = data.silverPrice;
      totalLaborCost.value = data.totalLaborCost;
      totalNetWeight.value = data.totalNetWeight;
      grandTotal.value = data.grandTotal;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItem(InventoryEntity item) async {
    final resolvedItemId =
        item.itemId ?? (item.id.isNotEmpty ? int.tryParse(item.id) : null);
    if (resolvedItemId == null) {
      showToast('Unable to add item', success: false);
      return;
    }
    final index = _indexFor(item);
    var newQty = 1;
    if (index >= 0) {
      final current = items[index];
      newQty = current.quantity + 1;
      items[index] = CartItemEntity(
        cartItemId: current.cartItemId,
        item: current.item,
        quantity: newQty,
      );
    } else {
      items.add(CartItemEntity(item: item, quantity: 1));
    }
    items.refresh();
    isUpdating.value = true;
    try {
      final added = await repository.addToCart(item, newQty);
      if (added != null) {
        final updateIndex = _indexFor(added.item);
        if (updateIndex >= 0) {
          final current = items[updateIndex];
          items[updateIndex] = CartItemEntity(
            cartItemId: added.cartItemId ?? current.cartItemId,
            item: added.item,
            quantity: current.quantity,
          );
          items.refresh();
        }
      }
      // Always re-fetch cart so totals/summary are accurate.
      await _refreshSilent();
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> removeItem(InventoryEntity item) async {
    final index = _indexFor(item);
    if (index >= 0) {
      final existing = items[index];
      items.removeAt(index);
      items.refresh();
      final cartItemId = existing.cartItemId?.trim();
      final productId = existing.item.itemId?.toString();
      if ((cartItemId == null || cartItemId.isEmpty) &&
          (productId == null || productId.isEmpty)) {
        showToast('Unable to remove item', success: false);
        await _refreshSilent();
        return;
      }
      isUpdating.value = true;
      try {
        if (cartItemId != null && cartItemId.isNotEmpty) {
          await repository.removeFromCart(id: cartItemId);
        } else if (productId != null && productId.isNotEmpty) {
          await repository.removeFromCart(id: productId);
        }
        await _refreshSilent();

        // Some server variants ignore cartItemId and require product/item id.
        // If item still exists after refresh, retry once with product id.
        if (_indexFor(existing.item) >= 0 &&
            productId != null &&
            productId.isNotEmpty &&
            productId != cartItemId) {
          await repository.removeFromCart(id: productId);
          await _refreshSilent();
        }
      } catch (e) {
        showToast('Failed to remove item', success: false);
        await _refreshSilent();
      } finally {
        isUpdating.value = false;
      }
    }
  }

  Future<void> increment(InventoryEntity item) async {
    await addItem(item);
  }

  Future<void> decrement(InventoryEntity item) async {
    final index = _indexFor(item);
    if (index >= 0) {
      final current = items[index];
      final newQty = current.quantity - 1;
      if (newQty <= 0) {
        await removeItem(item);
      } else {
        items[index] = CartItemEntity(item: current.item, quantity: newQty);
        items.refresh();
        isUpdating.value = true;
        try {
          await repository.addToCart(item, newQty);
          await _refreshSilent();
        } catch (e) {
          showToast('Failed to update quantity', success: false);
          await _refreshSilent();
        } finally {
          isUpdating.value = false;
        }
      }
    }
  }

  Future<void> setQuantity(InventoryEntity item, int quantity) async {
    if (quantity <= 0) {
      await removeItem(item);
      return;
    }
    final index = _indexFor(item);
    if (index >= 0) {
      items[index] = CartItemEntity(item: item, quantity: quantity);
    } else {
      items.add(CartItemEntity(item: item, quantity: quantity));
    }
    items.refresh();
    isUpdating.value = true;
    try {
      await repository.addToCart(item, quantity);
      await _refreshSilent();
    } catch (e) {
      showToast('Failed to update quantity', success: false);
      await _refreshSilent();
    } finally {
      isUpdating.value = false;
    }
  }

  double get total {
    if (grandTotal.value > 0) return grandTotal.value;
    return items.fold(0, (sum, e) => sum + e.item.price * e.quantity);
  }

  int get totalItems {
    return items.fold(0, (sum, e) => sum + e.quantity);
  }

  void clear() {
    items.clear();
    subtotal.value = 0;
    productDiscountTotal.value = 0;
    couponDiscount.value = 0;
    taxAmount.value = 0;
    shippingAmount.value = 0;
    silverPrice.value = 0;
    totalLaborCost.value = 0;
    totalNetWeight.value = 0;
    grandTotal.value = 0;
  }

  CartItemEntity? findItem(InventoryEntity item) {
    final index = _indexFor(item);
    if (index < 0) return null;
    return items[index];
  }

  int _indexFor(InventoryEntity item) {
    final itemId = item.itemId ?? int.tryParse(item.id);
    final zohoId = item.zohoBooksItemId;
    return items.indexWhere((e) {
      final otherId = e.item.itemId ?? int.tryParse(e.item.id);
      final otherZohoId = e.item.zohoBooksItemId;
      if (itemId != null && otherId != null) {
        return itemId == otherId;
      }
      if (zohoId != null && otherZohoId != null) {
        return zohoId == otherZohoId;
      }
      return e.item.id == item.id;
    });
  }

  Future<void> _refreshSilent() async {
    final data = await repository.fetchCart();
    items.assignAll(data.items);
    subtotal.value = data.subtotal;
    productDiscountTotal.value = data.productDiscountTotal;
    couponDiscount.value = data.couponDiscount;
    taxAmount.value = data.taxAmount;
    shippingAmount.value = data.shippingAmount;
    silverPrice.value = data.silverPrice;
    totalLaborCost.value = data.totalLaborCost;
    totalNetWeight.value = data.totalNetWeight;
    grandTotal.value = data.grandTotal;
  }
}
