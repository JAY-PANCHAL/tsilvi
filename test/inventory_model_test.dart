import 'package:flutter_test/flutter_test.dart';
import 'package:tsilvi/data/models/inventory_model.dart';

void main() {
  test('parses laborCostPerGm and productMedias images', () {
    final item = InventoryModel.fromJson({
      'id': 4911,
      'name': 'Ring',
      'sku': 'SKU',
      'description': '',
      'price': 1338.895,
      'netWeight': 4.045,
      'laborCostPerGm': 86,
      'silverPrice': 74,
      'productMedias': [
        {
          'webMedia': 'https://example.com/img (1).jpg',
          'mobMedia': 'https://example.com/img (1).jpg',
        }
      ],
    });

    expect(item.netWeight, 4.045);
    expect(item.laborCostPerGm, 86);
    expect(item.silverPrice, 74);
    expect(item.images, contains('https://example.com/img%20(1).jpg'));
  });

  test('keeps explicit non-zero laborCostPerGm when provided', () {
    final item = InventoryModel.fromJson({
      'id': 1,
      'name': 'Ring',
      'sku': 'SKU',
      'description': '',
      'price': 10,
      'netWeight': 2.0,
      'laborCostPerGm': 120,
      'laborCost': 240,
      'productMedias': [],
    });

    expect(item.laborCostPerGm, 120);
  });

  test('handles missing laborCostPerGm', () {
    final item = InventoryModel.fromJson({
      'id': 2,
      'name': 'Ring',
      'sku': 'SKU',
      'description': '',
      'price': 10,
      'netWeight': 2.0,
      'productMedias': [],
    });

    expect(item.laborCostPerGm, isNull);
  });
}
