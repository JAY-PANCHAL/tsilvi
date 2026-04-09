import 'package:intl/intl.dart';

import '../../domain/entities/order_entity.dart';

String buildOrderShareText(
  OrderEntity order, {
  required String customerName,
}) {
  final safeCustomerName =
      customerName.trim().isNotEmpty ? customerName.trim() : 'Customer';
  final totalQuantity = order.items.fold<int>(0, (sum, e) => sum + e.quantity);
  final totalNetWeight = order.totalNetWeight ??
      order.items.fold<double>(
        0,
        (sum, e) => sum + ((e.item.netWeight ?? 0) * e.quantity),
      );
  final totalLaborChargesAmount = order.totalLaborCost;
  final money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  final itemLines = order.items.map((e) {
    final skuText = e.item.sku.trim().isNotEmpty ? ' (${e.item.sku})' : '';
    final netWeightText =
        e.item.netWeight != null ? e.item.netWeight!.toStringAsFixed(3) : '[ ]';
    final laborRateText = e.item.laborCostPerGm != null
        ? 'Rs ${money.format(e.item.laborCostPerGm).replaceAll('₹', '').trim()}/gm'
        : 'Rs [ ]';
    final silverPriceText = e.item.silverPrice != null
        ? 'Rs ${money.format(e.item.silverPrice).replaceAll('₹', '').trim()}/gm'
        : 'Rs [ ]';
    return '* ${e.item.name}$skuText\n'
        '  Qty: ${e.quantity}\n'
        '  Net Weight: $netWeightText g\n'
        '  Labour Rate: $laborRateText\n'
        '  Silver Price: $silverPriceText';
  }).join('\n\n');

  return 'Thank you $safeCustomerName for your selection\n'
      'We truly appreciate your trust in us.\n\n'
      'Here are your order details:\n\n'
      '*Items Selected:*\n'
      '$itemLines\n\n'
      '----------\n'
      '*Summary:*\n'
      '* Total Quantity: $totalQuantity pcs\n'
      '* Total Net Weight: ${totalNetWeight > 0 ? totalNetWeight.toStringAsFixed(3) : "[ ]"} grams\n'
      '* Total Labour Charges: ${totalLaborChargesAmount != null ? money.format(totalLaborChargesAmount) : "₹[ ]"}\n'
      '* *Total Order Value: ${money.format(order.total)}*\n\n'
      '---\n\n'
      'Please review the above details\n\n'
      'Thank you once again for choosing us.\n'
      'Tsilivi Jewels Pvt Ltd.';
}
