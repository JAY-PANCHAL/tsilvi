import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/price_format.dart';
import '../../domain/entities/order_entity.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/gradient_background.dart';
import '../widgets/fade_slide.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as OrderEntity;
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(order.date);
    final currency =
        order.items.isNotEmpty ? order.items.first.item.currency : '';

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
                        'Order Details',
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassContainer(
                  radius: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        date,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total: ${formatCurrency(order.total, currency: currency, fractionDigits: 2)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      GlassIconButton(
                        icon: Icons.share_outlined,
                        label: 'Share Order',
                        onTap: () => Share.share(_shareText(order, date)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: order.items.isEmpty
                    ? const Center(
                        child: Text(
                          'No items recorded for this order',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: order.items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return FadeSlide(
                            index: index,
                            child: GlassContainer(
                              radius: 18,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      item.item.images.first,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.item.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Qty: ${item.quantity}',
                                          style: TextStyle(
                                              color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(
                                      item.item.price * item.quantity,
                                      currency: item.item.currency,
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
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shareText(OrderEntity order, String date) {
    final itemsText = order.items
        .map((e) => '${e.item.name} x${e.quantity}')
        .join(', ');
    final currency =
        order.items.isNotEmpty ? order.items.first.item.currency : '';
    return 'Order ID: ${order.id}\nDate: $date\nItems: $itemsText\nTotal: ${formatCurrency(order.total, currency: currency, fractionDigits: 2)}';
  }
}
