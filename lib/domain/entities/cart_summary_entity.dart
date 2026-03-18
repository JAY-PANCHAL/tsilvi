import 'cart_item_entity.dart';

class CartSummaryEntity {
  final List<CartItemEntity> items;
  final double subtotal;
  final double productDiscountTotal;
  final double couponDiscount;
  final double taxAmount;
  final double shippingAmount;
  final double grandTotal;
  final bool? isAuthenticated;
  final String? appliedCouponCode;

  CartSummaryEntity({
    required this.items,
    required this.subtotal,
    required this.productDiscountTotal,
    required this.couponDiscount,
    required this.taxAmount,
    required this.shippingAmount,
    required this.grandTotal,
    this.isAuthenticated,
    this.appliedCouponCode,
  });
}
