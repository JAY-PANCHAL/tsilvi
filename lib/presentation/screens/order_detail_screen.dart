import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/order_share_text.dart';
import '../../core/utils/price_format.dart';
import '../../core/utils/toast.dart';
import '../../domain/entities/order_entity.dart';
import '../controllers/users_controller.dart';
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
                      if (order.id.trim().isNotEmpty) ...[
                        Text(
                          order.id,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
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
                      if ((order.sku ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'SKU: ${order.sku}',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                      if (order.totalNetWeight != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Total Net Weight: ${order.totalNetWeight!.toStringAsFixed(3)} g',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                     /* if (order.silverPrice != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Silver Price: ${formatCurrency(order.silverPrice!, currency: "INR", fractionDigits: 2)}',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],*/
                      if (order.laborCostPerGm != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Labor Cost Per Gm: ${formatCurrency(order.laborCostPerGm!, currency: "INR", fractionDigits: 2)}',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: 14),
                      if (order.id.trim().isNotEmpty)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final max =
                                constraints.maxWidth > 520 ? 520.0 : constraints.maxWidth;
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: GlassIconButton(
                                icon: Icons.share_outlined,
                                label: 'Share Order',
                                onTap: () => _shareOrder(order),
                                fullWidth: true,
                                maxWidth: max,
                              ),
                            );
                          },
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
                          final money = NumberFormat.currency(
                            locale: 'en_IN',
                            symbol: '₹',
                            decimalDigits: 2,
                          );
                          return FadeSlide(
                            index: index,
                            child: GlassContainer(
                              radius: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: _OrderItemImage(urls: item.item.images),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.item.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.item.sku.trim().isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'SKU: ${item.item.sku}',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Net Weight: ${item.item.netWeight != null ? item.item.netWeight!.toStringAsFixed(3) : "-"} g',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Labour Rate: ${item.item.laborCostPerGm != null ? money.format(item.item.laborCostPerGm) : "-"}',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Silver Price: ${item.item.silverPrice != null ? money.format(item.item.silverPrice) : "-"}',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total: ${formatCurrency(item.item.price * item.quantity, currency: item.item.currency, fractionDigits: 2)}',
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

  String _shareText(OrderEntity order) {
    final selectedUser =
        Get.isRegistered<UsersController>() ? Get.find<UsersController>().selectedUser.value : null;
    final customerName =
        (selectedUser?.name.trim().isNotEmpty ?? false) ? selectedUser!.name.trim() : 'Customer';
    return buildOrderShareText(order, customerName: customerName);
  }

  Future<void> _shareOrder(OrderEntity order) async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: _shareText(order)),
      );
    } catch (_) {
      showToast('Unable to share order right now', success: false);
    }
  }
}

class _OrderItemImage extends StatelessWidget {
  final List<String> urls;

  const _OrderItemImage({required this.urls});

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return _fallback();
    }
    return Image.network(
      urls.first,
      width: 84,
      height: 84,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: 84,
      height: 84,
      color: Colors.white.withOpacity(0.12),
      child: const Icon(Icons.image_not_supported_outlined,
          color: Colors.white70, size: 22),
    );
  }
}
