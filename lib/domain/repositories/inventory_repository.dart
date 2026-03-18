import '../entities/inventory_entity.dart';

abstract class InventoryRepository {
  Future<List<InventoryEntity>> fetchInventory({
    required int page,
    required int limit,
    String query,
    String category,
  });

  Future<InventoryEntity?> fetchBySku(String sku);
}
