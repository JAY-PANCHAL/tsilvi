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
    final data = await api.post('/order/create', body: model.toJson());
    if (data is Map<String, dynamic>) {
      return OrderModel.fromJson(data);
    }
    return model;
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
