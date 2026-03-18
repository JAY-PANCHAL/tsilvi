import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> fetchOrders();
  Future<OrderEntity> createOrder(OrderEntity order);
}
