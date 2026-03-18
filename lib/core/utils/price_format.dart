String formatCurrency(
  double value, {
  String currency = '',
  int fractionDigits = 0,
}) {
  final amount = value.toStringAsFixed(fractionDigits);
  final code = currency.trim().isEmpty ? 'INR' : currency.trim();
  return '$code $amount';
}
