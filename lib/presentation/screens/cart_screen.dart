import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/price_format.dart';
import '../../core/utils/toast.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../routes/app_routes.dart';
import '../controllers/cart_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/users_controller.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/customer_required_dialog.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _showDetails = false;
  bool _didAutoLeaveEmptyCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final usersController = Get.find<UsersController>();
      if (!usersController.hasSelectedUser) {
        await showCustomerRequiredDialog();
      } else {
        await Get.find<CartController>().fetchCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final ordersController = Get.find<OrdersController>();
    final usersController = Get.find<UsersController>();

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
                    const Expanded(
                      child: Text(
                        'Cart',
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
              // ── Cart items ─────────────────────────────────────────
              Expanded(
                child: Obx(
                  () {
                    if (!usersController.hasSelectedUser) {
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: GlassContainer(
                              radius: 22,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person_outline,
                                      color: Colors.white70, size: 42),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Select Customer to Continue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Cart is linked to a customer profile.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 16),
                                  GlassButton(
                                    label: 'Add New Customer',
                                    onTap: () =>
                                        Get.toNamed(AppRoutes.addUser),
                                  ),
                                  const SizedBox(height: 10),
                                  GlassButton(
                                    label: 'Choose Existing',
                                    onTap: () => Get.toNamed(
                                        AppRoutes.existingUsers),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    // If cart becomes empty, send user back to inventory to keep
                    // the flow intact (especially after deleting the last item).
                    if (!cartController.isLoading.value &&
                        !cartController.isUpdating.value &&
                        cartController.items.isEmpty) {
                      if (!_didAutoLeaveEmptyCart) {
                        _didAutoLeaveEmptyCart = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          if (Get.currentRoute == AppRoutes.cart) {
                            Get.offNamed(AppRoutes.inventory);
                          }
                        });
                      }
                      return const SizedBox.shrink();
                    }
                    if (cartController.items.isNotEmpty) {
                      _didAutoLeaveEmptyCart = false;
                    }
                    final user = usersController.selectedUser.value;
                    final headerCount = user == null ? 0 : 1;
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 200),
                      itemCount: cartController.items.length + headerCount,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (headerCount == 1 && index == 0) {
                          return GlassContainer(
                            radius: 16,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user!.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (user.mobile.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone,
                                                color: Colors.white54,
                                                size: 13),
                                            const SizedBox(width: 4),
                                            Text(
                                              user.mobile,
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (user.email.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.email_outlined,
                                                color: Colors.white54,
                                                size: 13),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                user.email,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.existingUsers),
                                  child: const Text(
                                    'Change',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        final item = cartController.items[index - headerCount];
                        return Dismissible(
                          key: ValueKey(item.item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          onDismissed: (_) async =>
                              await cartController.removeItem(item.item),
                          child: _CartItemCard(
                            item: item,
                            onMinus: () async =>
                                await cartController.decrement(item.item),
                            onPlus: () async =>
                                await cartController.increment(item.item),
                            onQuantity: (qty) {
                              cartController.setQuantity(item.item, qty);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              
                ],
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: Obx(
                  () => SafeArea(
                    top: false,
                    child: GlassContainer(
                      radius: 20,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _TotalRow(
                            label: 'Grand Total',
                            value: cartController.grandTotal.value,
                            isEmphasis: true,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  setState(() => _showDetails = !_showDetails),
                              icon: Icon(
                                _showDetails
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white70,
                              ),
                              label: Text(
                                _showDetails ? 'Hide details' : 'Show details',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                          if (_showDetails) ...[
                            if (cartController.subtotal.value > 0)
                              _TotalRow(
                                label: 'Subtotal',
                                value: cartController.subtotal.value,
                              ),
                            if (cartController.totalLaborCost.value > 0)
                              _TotalRow(
                                label: 'Total Labour Cost',
                                value: cartController.totalLaborCost.value,
                              ),
                            if (cartController.totalNetWeight.value > 0)
                              _ValueRow(
                                label: 'Total Net Weight',
                                value:
                                    '${cartController.totalNetWeight.value.toStringAsFixed(3)} g',
                              ),
                            if (cartController.productDiscountTotal.value > 0)
                              _TotalRow(
                                label: 'Product Discount',
                                value:
                                    cartController.productDiscountTotal.value,
                              ),
                            if (cartController.couponDiscount.value > 0)
                              _TotalRow(
                                label: 'Coupon Discount',
                                value: cartController.couponDiscount.value,
                              ),
                            if (cartController.taxAmount.value > 0)
                              _TotalRow(
                                label: 'Tax',
                                value: cartController.taxAmount.value,
                              ),
                            if (cartController.shippingAmount.value > 0)
                              _TotalRow(
                                label: 'Shipping',
                                value: cartController.shippingAmount.value,
                              ),
                          ],
                          const SizedBox(height: 12),
                          GlassButton(
                            label: 'Checkout',
                            onTap: () async {
                              if (cartController.items.isEmpty) return;
                              if (!usersController.hasSelectedUser) return;
                              try {
                                final selectedUser =
                                    usersController.selectedUser.value;
                                final customerId = selectedUser == null
                                    ? null
                                    : (int.tryParse(selectedUser.id) ??
                                        selectedUser.id);
                                if (customerId == null) {
                                  showToast(
                                    'Please select a customer',
                                    success: false,
                                  );
                                  return;
                                }
                                final order =
                                    await ordersController.createOrder(
                                  cartController.items,
                                  cartController.total,
                                  customerId: customerId,
                                );
                                cartController.clear();
                                Get.toNamed(AppRoutes.success,
                                    arguments: order);
                              } catch (e) {
                                final msg = e.toString().replaceFirst(
                                    'Exception: ', '');
                                showToast(
                                  msg.isNotEmpty
                                      ? msg
                                      : 'Checkout failed',
                                  success: false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () => (cartController.isLoading.value ||
                        cartController.isUpdating.value)
                    ? const _CartFullScreenLoader()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatefulWidget {
  final CartItemEntity item;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<int> onQuantity;

  const _CartItemCard({
    required this.item,
    required this.onMinus,
    required this.onPlus,
    required this.onQuantity,
  });

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.item.quantity}');
  }

  @override
  void didUpdateWidget(covariant _CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = '${widget.item.quantity}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displaySku = widget.item.item.sku.trim().isNotEmpty
        ? widget.item.item.sku.trim()
        : (widget.item.item.itemId?.toString() ??
            int.tryParse(widget.item.item.id)?.toString() ??
            '');
    return PressableScale(
      child: GlassContainer(
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.item.item.images.isNotEmpty
                  ? Image.network(
                      widget.item.item.images.first,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        color: Colors.white12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.white54, size: 22),
                      ),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: Colors.white12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white54, size: 22),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (displaySku.isNotEmpty)
                    Text(
                      'SKU: $displaySku',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  if (widget.item.item.netWeight != null ||
                      widget.item.item.laborCostPerGm != null) ...[
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.item.item.netWeight != null)
                          Text(
                            'Net Wt: ${widget.item.item.netWeight!.toStringAsFixed(3)} g',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        if (widget.item.item.laborCostPerGm != null)
                          Text(
                            'Labour rate: ${formatCurrency(widget.item.item.laborCostPerGm!, currency: "INR", fractionDigits: 0)}/gm',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        if (widget.item.item.silverPrice != null)
                          Text(
                            'Silver: ${formatCurrency(widget.item.item.silverPrice!, currency: "INR", fractionDigits: 0)}/gm',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ],
                  if ((widget.item.item.color ?? '').isNotEmpty ||
                      (widget.item.item.size ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if ((widget.item.item.color ?? '').isNotEmpty)
                          'Color: ${widget.item.item.color}',
                        if ((widget.item.item.size ?? '').isNotEmpty)
                          'Size: ${widget.item.item.size}',
                      ].join(' • '),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatCurrency(
                            widget.item.item.price,
                            currency: widget.item.item.currency,
                            fractionDigits: 0,
                          ),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      _QuantityControl(
                        controller: _controller,
                        onMinus: widget.onMinus,
                        onPlus: widget.onPlus,
                        onChanged: (value) {
                          final qty =
                              int.tryParse(value) ?? widget.item.quantity;
                          widget.onQuantity(qty);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<String> onChanged;

  const _QuantityControl({
    required this.controller,
    required this.onMinus,
    required this.onPlus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove, color: Colors.white70, size: 18),
          ),
          SizedBox(
            width: 36,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add, color: Colors.white70, size: 18),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isEmphasis;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isEmphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
        final currency = cartController.items.isNotEmpty
        ? cartController.items.first.item.currency
        : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isEmphasis ? 16 : 14,
              fontWeight: isEmphasis ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            formatCurrency(value, currency: currency, fractionDigits: 2),
            style: TextStyle(
              color: Colors.white,
              fontSize: isEmphasis ? 18 : 14,
              fontWeight: isEmphasis ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _ValueRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartFullScreenLoader extends StatelessWidget {
  const _CartFullScreenLoader();

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
