import '../../domain/entities/inventory_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/api_service.dart';
import '../models/inventory_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final ApiService api;

  InventoryRepositoryImpl(this.api);

  @override
  Future<List<InventoryEntity>> fetchInventory({
    required int page,
    required int limit,
    String query = '',
    String category = '',
  }) {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category.isNotEmpty) {
      params['category'] = category;
    }
    if (query.isNotEmpty) {
      params['search'] = query;
    }
    return api
        .get('/inventory', query: params)
        .then((data) => _extractList(data)
            .map((e) => InventoryModel.fromJson(e))
            .toList());
  }

  @override
  Future<InventoryEntity?> fetchBySku(String sku) async {
    final encoded = Uri.encodeComponent(sku);
    final data = await api.get('/inventory/$encoded');
    if (data is Map<String, dynamic>) {
      return InventoryModel.fromJson(data);
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    List<Map<String, dynamic>> toMapList(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    }
    if (data is List) {
      return toMapList(data);
    }
    if (data is Map<String, dynamic>) {
      final dataNode = data['data'];
      if (dataNode is Map<String, dynamic>) {
        final nested = dataNode['items'] ??
            dataNode['products'] ??
            dataNode['productCardVMs'];
        if (nested is List) {
          return toMapList(nested);
        }
      }
      final resultNode = data['result'];
      if (resultNode is Map<String, dynamic>) {
        final list = resultNode['productCardVMs'] ??
            resultNode['items'] ??
            resultNode['products'];
        if (list is List) {
          return toMapList(list);
        }
      }
      final list = data['data'] ?? data['items'] ?? data['products'];
      if (list is List) {
        return toMapList(list);
      }
    }
    return [];
  }
}
