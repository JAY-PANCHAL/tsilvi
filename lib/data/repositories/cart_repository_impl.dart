import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/inventory_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/api_service.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  final ApiService api;

  CartRepositoryImpl(this.api);

  @override
  Future<List<CartItemEntity>> fetchCart() async {
    final data = await api.get('/cart');
    final list = _extractList(data);
    return list.map((e) => CartModel.fromJson(e)).toList();
  }

  @override
  Future<CartItemEntity?> addToCart(InventoryEntity item, int quantity) async {
    final resolvedItemId = item.itemId ??
        (item.id.isNotEmpty ? int.tryParse(item.id) : null);
    if (resolvedItemId == null) return null;
    final body = {
      'itemId': resolvedItemId,
      'zohoBooksItemId': item.zohoBooksItemId ?? 0,
      'quantity': quantity,
      'unitPrice': item.price,
      'productDiscountAmount': 0,
    };
    final data = await api.post('/cart/add', body: body);
    if (data is Map<String, dynamic>) {
      return CartModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    await api.delete('/cart/$cartItemId');
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final dataNode = data['data'];
      if (dataNode is Map<String, dynamic>) {
        final nested = dataNode['items'] ?? dataNode['cartItems'];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
      }
      final list = data['data'] ?? data['items'] ?? data['cartItems'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }
}
