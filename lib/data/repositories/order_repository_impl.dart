import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/api_service.dart';
import '../models/order_model.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final ApiService api;

  OrderRepositoryImpl(this.api);

  @override
  Future<List<OrderEntity>> fetchOrders() async {
    final data = await api.get('/order/list');
    final list = _extractList(data);
    return list.map((e) => OrderModel.fromJson(e)).toList();
  }

  @override
  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    final model = OrderModel(
      id: order.id,
      date: order.date,
      total: order.total,
      items: order.items,
    );
    final body = {
      ...model.toJson(),
      'customerId': 117,
    };
    final data = await api.post('/order/create', body: body);
    if (!_isSuccess(data)) {
      final msg = _extractMessage(data) ?? 'Unable to place order';
      throw Exception(msg);
    }
    if (data is Map<String, dynamic>) {
      return OrderModel.fromJson(data);
    }
    return model;
  }

  bool _isSuccess(dynamic data) {
    if (data is Map<String, dynamic>) {
      final status = data['_statusCode'];
      if (status is int && (status < 200 || status >= 300)) return false;
      final s = data['success'] ?? data['status'];
      final nested = data['data'];
      final s2 = nested is Map<String, dynamic>
          ? (nested['success'] ?? nested['status'])
          : null;
      final value = s ?? s2;
      if (value is bool) return value;
      if (value is num) return value == 1 || value == 200;
      if (value is String) {
        final v = value.toLowerCase();
        return v == 'true' || v == 'success' || v == 'ok';
      }
      return true;
    }
    return true;
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['msg']?.toString() ??
          (data['data'] is Map<String, dynamic>
              ? (data['data']['message']?.toString() ??
                  data['data']['msg']?.toString())
              : null);
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final dataNode = data['data'];
      if (dataNode is Map<String, dynamic>) {
        final nested = dataNode['items'] ?? dataNode['orders'];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
      }
      final list = data['data'] ?? data['items'] ?? data['orders'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }
}
