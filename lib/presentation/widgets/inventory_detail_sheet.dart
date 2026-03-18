import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/price_format.dart';
import '../../domain/entities/inventory_entity.dart';
import '../../routes/app_routes.dart';
import '../controllers/cart_controller.dart';
import '../controllers/users_controller.dart';
import 'customer_required_dialog.dart';
import 'glass_button.dart';
import 'glass_container.dart';

class InventoryDetailSheet extends StatelessWidget {
  final InventoryEntity item;

  const InventoryDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final usersController = Get.find<UsersController>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: GlassContainer(
          radius: 24,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              CarouselSlider(
                options: CarouselOptions(
                  height: 220,
                  enlargeCenterPage: true,
                  autoPlay: true,
                ),
                items: item.images.isEmpty
                    ? [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: double.infinity,
                            color: Colors.white12,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.white54, size: 48),
                          ),
                        ),
                      ]
                    : item.images.map((image) {
                        return GestureDetector(
                          onTap: () =>
                              Get.toNamed(AppRoutes.gallery, arguments: item),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              image,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: double.infinity,
                                color: Colors.white12,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.white54, size: 48),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.sku,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                item.description,
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                formatCurrency(
                  item.price,
                  currency: item.currency,
                  fractionDigits: 2,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              GlassButton(
                label: 'Add to Cart',
                onTap: () async {
                  if (!usersController.hasSelectedUser) {
                    await showCustomerRequiredDialog();
                    return;
                  }
                  await cartController.addItem(item);
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
