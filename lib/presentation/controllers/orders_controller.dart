import 'package:get/get.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrdersController extends GetxController {
  final OrderRepository repository;

  OrdersController(this.repository);

  final orders = <OrderEntity>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    final data = await repository.fetchOrders();
    orders.assignAll(data);
    isLoading.value = false;
  }

  Future<OrderEntity> createOrder(
    List<CartItemEntity> items,
    double total, {
    required dynamic customerId,
  }) async {
    final order = OrderEntity(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}',
      customerId: customerId,
      sku: null,
      silverPrice: null,
      laborCostPerGm: null,
      totalLaborCost: null,
      totalNetWeight: null,
      date: DateTime.now(),
      total: total,
      items: items,
    );
    final created = await repository.createOrder(order);
    orders.insert(0, created);
    return created;
  }
}
