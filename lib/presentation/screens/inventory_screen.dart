import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/price_format.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/inventory_entity.dart';
import '../../routes/app_routes.dart';
import '../controllers/cart_controller.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/users_controller.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/customer_required_dialog.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/inventory_detail_sheet.dart';
import '../widgets/shimmer_loader.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryController>();
    final cartController = Get.find<CartController>();
    final usersController = Get.find<UsersController>();
    final columns = Responsive.gridCount(context, mobile: 1, tablet: 2);

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
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Inventory',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.toNamed(AppRoutes.qrScanner),
                      icon: const Icon(Icons.qr_code_scanner,
                          color: Colors.white),
                    ),
                    const CartIconButton(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search by name or SKU',
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                  ),
                  onChanged: controller.updateQuery,
                  onSubmitted: controller.searchBySku,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () {
                  if (controller.categories.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 72,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        return Obx(() {
                          final selectedCategory =
                              controller.selectedCategory.value;
                          final selected = selectedCategory == null
                              ? false
                              : (selectedCategory.slug.isNotEmpty &&
                                  selectedCategory.slug == category.slug) ||
                                  (selectedCategory.slug.isEmpty &&
                                      selectedCategory.name.toLowerCase() ==
                                          category.name.toLowerCase());
                          return GestureDetector(
                            onTap: () => controller.selectCategory(category),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white.withOpacity(0.22)
                                    : Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (category.imageUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        category.imageUrl,
                                        width: 34,
                                        height: 34,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 34,
                                          height: 34,
                                          color: Colors.white12,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white54,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    const Icon(Icons.category,
                                        color: Colors.white70, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoading.value) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: columns == 1 ? 2.5 : 2.4,
                        ),
                        itemCount: columns == 1 ? 6 : 8,
                        itemBuilder: (_, __) =>
                            const ShimmerListTile(height: 96),
                      );
                    }
                    if (controller.items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: controller.fetchInitial,
                        child: ListView(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.all(20),
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Text(
                                'No items found for this category',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: controller.fetchInitial,
                      child: GridView.builder(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: columns == 1 ? 2.5 : 2.4,
                        ),
                        itemCount: controller.items.length + 1,
                        itemBuilder: (context, index) {
                          if (index == controller.items.length) {
                            return Obx(
                              () => controller.isLoadingMore.value
                                  ? const ShimmerListTile(height: 72)
                                  : const SizedBox.shrink(),
                            );
                          }
                          final item = controller.items[index];
                          return FadeSlide(
                            index: index,
                            child: _InventoryCard(
                              item: item,
                              onTap: () => _openDetail(item),
                              onAdd: () async {
                                if (!usersController.hasSelectedUser) {
                                  await showCustomerRequiredDialog();
                                  return;
                                }
                                await cartController.addItem(item);
                              },
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

  void _openDetail(InventoryEntity item) {
    Get.bottomSheet(
      InventoryDetailSheet(item: item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryEntity item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _InventoryCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
        return PressableScale(
          onTap: onTap,
          child: GlassContainer(
            radius: 20,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.images.isNotEmpty
                      ? Image.network(
                          item.images.first,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.white12,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.white54, size: 26),
                          ),
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          color: Colors.white12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white54, size: 26),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.sku,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatCurrency(
                          item.price,
                          currency: item.currency,
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
                const SizedBox(width: 8),
                Obx(
                  () {
                    final isAdded = cartController.items
                        .any((element) => element.item.id == item.id);
                    return Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onAdd,
                        icon: Icon(
                          isAdded ? Icons.check : Icons.add,
                          color: isAdded ? Colors.greenAccent : Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }
    }
