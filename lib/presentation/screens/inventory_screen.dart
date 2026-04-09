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
import '../widgets/glass_button.dart';
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
          child: Stack(
            children: [
              Column(
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
                    const CartIconButton(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by name or SKU',
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white70),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final result =
                                  await Get.toNamed(AppRoutes.qrScanner);
                              if (result is String && result.trim().isNotEmpty) {
                                await controller.searchBySku(result.trim());
                              }
                            },
                            icon: const Icon(Icons.qr_code_scanner,
                                color: Colors.white70),
                          ),
                        ),
                        onChanged: controller.updateQuery,
                        onSubmitted: controller.updateQuery,
                      ),
                    ),
                  ],
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
                      if (columns == 1) {
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                          itemCount: 6,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, __) =>
                              const ShimmerListTile(height: 96),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.55,
                        ),
                        itemCount: 8,
                        itemBuilder: (_, __) =>
                            const ShimmerListTile(height: 96),
                      );
                    }
                    if (controller.items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: controller.fetchInitial,
                        child: ListView(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
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
                      child: columns == 1
                          ? ListView.separated(
                              controller: controller.scrollController,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 120),
                              itemCount: controller.items.length + 1,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
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
                                  child: Obx(() {
                                    final cartEntry =
                                        cartController.findItem(item);
                                    final qty = cartEntry?.quantity ?? 0;
                                    return _InventoryCard(
                                      item: item,
                                      quantity: qty,
                                      onTap: () => _openDetail(item),
                                      onAdd: () async {
                                        if (!usersController.hasSelectedUser) {
                                          await showCustomerRequiredDialog();
                                          return;
                                        }
                                        await cartController.addItem(item);
                                      },
                                      onIncrement: () async {
                                        await cartController.increment(item);
                                      },
                                      onDecrement: () async {
                                        await cartController.decrement(item);
                                      },
                                      onSetQuantity: (qty) {
                                        cartController.setQuantity(item, qty);
                                      },
                                    );
                                  }),
                                );
                              },
                            )
                          : GridView.builder(
                              controller: controller.scrollController,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 120),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.55,
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
                                  child: Obx(() {
                                    final cartEntry =
                                        cartController.findItem(item);
                                    final qty = cartEntry?.quantity ?? 0;
                                    return _InventoryCard(
                                      item: item,
                                      quantity: qty,
                                      onTap: () => _openDetail(item),
                                      onAdd: () async {
                                        if (!usersController.hasSelectedUser) {
                                          await showCustomerRequiredDialog();
                                          return;
                                        }
                                        await cartController.addItem(item);
                                      },
                                      onIncrement: () async {
                                        await cartController.increment(item);
                                      },
                                      onDecrement: () async {
                                        await cartController.decrement(item);
                                      },
                                      onSetQuantity: (qty) {
                                        cartController.setQuantity(item, qty);
                                      },
                                    );
                                  }),
                                );
                              },
                            ),
                    );
                  },
                ),
              ),
                ],
              ),
              Obx(
                () => cartController.items.isNotEmpty
                    ? Positioned(
                        left: 20,
                        right: 20,
                        bottom: 16,
                        child: GlassButton(
                          label: 'Go to Cart',
                          onTap: () => Get.toNamed(AppRoutes.cart),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => (controller.isLoading.value ||
                        cartController.isUpdating.value)
                    ? const _FullScreenLoader()
                    : const SizedBox.shrink(),
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

class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
class _InventoryCard extends StatefulWidget {
  final InventoryEntity item;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onSetQuantity;
  final int quantity;

  const _InventoryCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSetQuantity,
    required this.quantity,
  });

  @override
  State<_InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<_InventoryCard> {
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController =
        TextEditingController(text: widget.quantity > 0 ? '${widget.quantity}' : '');
  }

  @override
  void didUpdateWidget(covariant _InventoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      _qtyController.text =
          widget.quantity > 0 ? '${widget.quantity}' : '';
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displaySku = widget.item.sku.trim();
    return PressableScale(
      onTap: widget.onTap,
      child: GlassContainer(
        radius: 20,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.item.images.isNotEmpty
                  ? Image.network(
                      widget.item.images.first,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.white12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.white54, size: 26),
                      ),
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      color: Colors.white12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white54, size: 26),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tightHeight = constraints.maxHeight < 92;
                  final nameMaxLines = tightHeight ? 1 : 2;
                  final nameFontSize = tightHeight ? 14.0 : 15.0;
                  final skuFontSize = tightHeight ? 12.0 : 13.0;
                  final metaFontSize = tightHeight ? 12.0 : 13.0;
                  final gapSm = tightHeight ? 2.0 : 4.0;
                  final gapMd = tightHeight ? 4.0 : 6.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        maxLines: nameMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: nameFontSize,
                        ),
                      ),
                      if (displaySku.isNotEmpty) ...[
                        SizedBox(height: gapSm),
                        Text(
                          'SKU: $displaySku',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: skuFontSize,
                          ),
                        ),
                      ],
                      if (widget.item.netWeight != null ||
                          widget.item.laborCostPerGm != null) ...[
                        SizedBox(height: gapSm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.item.netWeight != null)
                              Text(
                                'Net Wt: ${widget.item.netWeight!.toStringAsFixed(3)} g',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: metaFontSize,
                                ),
                              ),
                            if (widget.item.laborCostPerGm != null)
                              Text(
                                'Labour rate: ${formatCurrency(widget.item.laborCostPerGm!, currency: "INR", fractionDigits: 0)}/gm',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: metaFontSize,
                                ),
                              ),
                          ],
                        ),
                      ],
                      SizedBox(height: gapMd),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final qtyWidget = widget.quantity > 0
                              ? _QtyControl(
                                  controller: _qtyController,
                                  onMinus: widget.onDecrement,
                                  onPlus: widget.onIncrement,
                                  onChanged: (value) {
                                    final qty = int.tryParse(value) ??
                                        widget.quantity;
                                    widget.onSetQuantity(qty);
                                  },
                                )
                              : Container(
                                  width: tightHeight ? 32 : 34,
                                  height: tightHeight ? 32 : 34,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: widget.onAdd,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: tightHeight ? 16 : 18,
                                    ),
                                  ),
                                );

                          final priceWidget = Text(
                            formatCurrency(
                              widget.item.price,
                              currency: widget.item.currency,
                              fractionDigits: 0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: tightHeight ? 13 : 14,
                            ),
                          );

                          return Row(
                            children: [
                              Expanded(child: priceWidget),
                              qtyWidget,
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<String> onChanged;

  const _QtyControl({
    required this.controller,
    required this.onMinus,
    required this.onPlus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove, color: Colors.white70, size: 16),
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 34,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 2),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add, color: Colors.white70, size: 16),
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
