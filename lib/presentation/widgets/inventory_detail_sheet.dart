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
    final images = item.images.where((e) => e.trim().isNotEmpty).toList();
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
              if (images.isEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.white12,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white54, size: 48),
                  ),
                )
              else
                CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 220,
                    enlargeCenterPage: images.length > 1,
                    autoPlay: images.length > 1,
                    enableInfiniteScroll: images.length > 1,
                    viewportFraction: 0.9,
                  ),
                  itemCount: images.length,
                  itemBuilder: (_, index, __) => _ZoomableImage(
                    image: images[index],
                    item: item,
                  ),
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
              if (item.sku.trim().isNotEmpty)
                Text(
                  item.sku.trim(),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              const SizedBox(height: 12),
              if (item.description.trim().isNotEmpty)
                Text(
                  item.description.trim(),
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 12),
              if (item.netWeight != null ||
                  item.laborCostPerGm != null ||
                  item.silverPrice != null ||
                  (item.color != null && item.color!.trim().isNotEmpty) ||
                  (item.size != null && item.size!.trim().isNotEmpty))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: Column(
                    children: [
                      if (item.netWeight != null)
                        _DetailLine(
                          label: 'Net Weight',
                          value: '${item.netWeight!.toStringAsFixed(3)} g',
                        ),
                      if (item.laborCostPerGm != null)
                        _DetailLine(
                          label: 'Labour rate',
                          value:
                              '${formatCurrency(item.laborCostPerGm!, currency: 'INR', fractionDigits: 0)}/gm',
                        ),
                      if (item.silverPrice != null)
                        _DetailLine(
                          label: 'Silver Rate / gm',
                          value: formatCurrency(
                            item.silverPrice!,
                            currency: 'INR',
                            fractionDigits: 0,
                          ),
                        ),
                      if (item.color != null && item.color!.trim().isNotEmpty)
                        _DetailLine(label: 'Color', value: item.color!.trim()),
                      if (item.size != null && item.size!.trim().isNotEmpty)
                        _DetailLine(label: 'Size', value: item.size!.trim()),
                    ],
                  ),
                ),
              if (item.netWeight != null ||
                  item.laborCostPerGm != null ||
                  item.silverPrice != null ||
                  (item.color != null && item.color!.trim().isNotEmpty) ||
                  (item.size != null && item.size!.trim().isNotEmpty))
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

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final String image;
  final InventoryEntity item;

  const _ZoomableImage({required this.image, required this.item});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  late final ImageStream _stream;
  ImageStreamListener? _listener;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _stream = NetworkImage(widget.image).resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
      (_, __) {
        if (mounted && _hasError) {
          setState(() => _hasError = false);
        }
      },
      onError: (_, __) {
        if (mounted && !_hasError) {
          setState(() => _hasError = true);
        }
      },
    );
    _stream.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_listener != null) {
      _stream.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canZoom = !_hasError;
    return GestureDetector(
      onTap: canZoom
          ? () => Get.toNamed(AppRoutes.gallery, arguments: widget.item)
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          widget.image,
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
  }
}
