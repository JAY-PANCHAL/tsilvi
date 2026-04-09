import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/price_format.dart';
import '../../domain/entities/order_entity.dart';
import '../../routes/app_routes.dart';
import '../controllers/orders_controller.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/shimmer_loader.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<OrdersController>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Order History',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoading.value) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: 6,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (_, __) => const ShimmerListTile(),
                      );
                    }
                    if (controller.orders.isEmpty) {
                      return const Center(
                        child: Text(
                          'No orders yet',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: controller.fetchOrders,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: controller.orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final order = controller.orders[index];
                          return _OrderCard(
                            order: order,
                            onTap: () => Get.toNamed(
                              AppRoutes.orderDetail,
                              arguments: order,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy').format(order.date);
    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        radius: 20,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.12),
              child: const Icon(Icons.receipt_long_outlined,
                  color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${order.items.length} items · $date',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  if ((order.sku ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${order.sku}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  if (order.totalNetWeight != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Net Wt: ${order.totalNetWeight!.toStringAsFixed(3)} g',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  if (order.laborCostPerGm != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Labour rate: ${formatCurrency(order.laborCostPerGm!, currency: "INR", fractionDigits: 2)}/gm',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              formatCurrency(
                order.total,
                currency: order.items.isNotEmpty
                    ? order.items.first.item.currency
                    : '',
                fractionDigits: 0,
              ),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
