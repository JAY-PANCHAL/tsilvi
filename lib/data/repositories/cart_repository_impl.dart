import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_summary_entity.dart';
import '../../domain/entities/inventory_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/api_service.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  final ApiService api;

  CartRepositoryImpl(this.api);

  @override
  Future<CartSummaryEntity> fetchCart() async {
    final data = await api.get('/cart');
    final list = _extractList(data);
    final items = list.map((e) => CartModel.fromJson(e)).toList();
    final summary = _extractSummary(data);
    return CartSummaryEntity(
      items: items,
      subtotal: summary.subtotal,
      productDiscountTotal: summary.productDiscountTotal,
      couponDiscount: summary.couponDiscount,
      taxAmount: summary.taxAmount,
      shippingAmount: summary.shippingAmount,
      silverPrice: summary.silverPrice,
      totalLaborCost: summary.totalLaborCost,
      totalNetWeight: summary.totalNetWeight,
      grandTotal: summary.grandTotal,
      isAuthenticated: summary.isAuthenticated,
      appliedCouponCode: summary.appliedCouponCode,
    );
  }

  @override
  Future<CartItemEntity?> addToCart(InventoryEntity item, int quantity) async {
    final resolvedItemId =
        item.itemId ?? (item.id.isNotEmpty ? int.tryParse(item.id) : null);
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
  Future<void> removeFromCart({required String id, String? itemId}) async {
    // Some backend builds expect the id as a path segment (no `id=`),
    // others expect it as a query param. Try the path form first.
    final res = await api.post('/cart/delete/$id');
    if (res is Map<String, dynamic> && res['_statusCode'] == 404) {
      await api.post('/cart/delete', query: {'id': id});
    }
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

  CartSummaryEntity _extractSummary(dynamic data) {
    Map<String, dynamic> node = {};
    if (data is Map<String, dynamic>) {
      // Most endpoints wrap as { data: {...} } but some return flat payloads.
      final dataNode = data['data'];
      if (dataNode is Map) {
        node = Map<String, dynamic>.from(dataNode);
      } else {
        node = Map<String, dynamic>.from(data);
      }
      // Some payloads nest totals under `summary` or `cart`.
      final summaryNode = node['summary'];
      if (summaryNode is Map) {
        node = Map<String, dynamic>.from(summaryNode);
      }
      final cartNode = node['cart'];
      if (cartNode is Map) {
        node = Map<String, dynamic>.from(cartNode);
      }
    }
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    return CartSummaryEntity(
      items: const [],
      subtotal: toDouble(node['subtotal'] ?? node['subTotal']),
      productDiscountTotal:
          toDouble(node['productDiscountTotal'] ?? node['discountTotal']),
      couponDiscount: toDouble(node['couponDiscount'] ?? node['couponAmount']),
      taxAmount: toDouble(node['taxAmount'] ?? node['tax']),
      shippingAmount: toDouble(node['shippingAmount'] ?? node['shipping']),
      silverPrice: toDouble(
        node['silverPrice'] ?? node['totalSilverPrice'] ?? node['silverRate'],
      ),
      totalLaborCost: toDouble(
        node['totalLaborCost'] ??
            node['totalLabourCharges'] ??
            node['totalLabourCost'],
      ),
      totalNetWeight: toDouble(
        node['totalNetWeight'] ?? node['netWeight'] ?? node['totalNetWt'],
      ),
      grandTotal: toDouble(
        node['grandTotal'] ?? node['total'] ?? node['totalAmount'],
      ),
      isAuthenticated: node['isAuthenticated'] as bool?,
      appliedCouponCode: node['appliedCouponCode']?.toString(),
    );
  }
}
