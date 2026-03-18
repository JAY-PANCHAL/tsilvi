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
    if (index >= 0) {
      final current = items[index];
      items[index] = CartItemEntity(
        cartItemId: current.cartItemId,
        item: current.item,
        quantity: current.quantity + 1,
      );
    } else {
      items.add(CartItemEntity(item: item, quantity: 1));
    }
    items.refresh();
    isUpdating.value = true;
    try {
      final added = await repository.addToCart(item, 1);
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
      } else {
        await _refreshSilent();
      }
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
      if (existing.cartItemId != null) {
        isUpdating.value = true;
        try {
          await repository.removeFromCart(existing.cartItemId!);
        } finally {
          isUpdating.value = false;
        }
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
          await repository.addToCart(item, -1);
        } finally {
          isUpdating.value = false;
        }
      }
    }
  }

  void setQuantity(InventoryEntity item, int quantity) {
    if (quantity <= 0) {
      removeItem(item);
      return;
    }
    final index = _indexFor(item);
    if (index >= 0) {
      items[index] = CartItemEntity(item: item, quantity: quantity);
    } else {
      items.add(CartItemEntity(item: item, quantity: quantity));
    }
    items.refresh();
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
    grandTotal.value = data.grandTotal;
  }
}
