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
    return api.get('/inventory', query: params).then((data) =>
        _extractList(data).map((e) => InventoryModel.fromJson(e)).toList());
  }

  @override
  Future<InventoryEntity?> fetchBySku(String sku) async {
    final encoded = Uri.encodeComponent(sku);
    final data = await api.get('/inventory/$encoded');
    if (data is Map<String, dynamic>) {
      final dataNode = data['data'];
      if (dataNode is Map<String, dynamic> && _isValidItem(dataNode)) {
        return InventoryModel.fromJson(dataNode);
      }
      final list = _extractList(data);
      if (list.isNotEmpty) {
        return InventoryModel.fromJson(list.first);
      }
      if (_isValidItem(data)) {
        return InventoryModel.fromJson(data);
      }
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
      final searchResultNode = data['searchResult'];
      if (searchResultNode is Map<String, dynamic>) {
        final searchItems = searchResultNode['productCardVMs'] ??
            searchResultNode['items'] ??
            searchResultNode['products'];
        if (searchItems is List) {
          return toMapList(searchItems);
        }
      }
      final dataNode = data['data'];
      if (dataNode is Map<String, dynamic>) {
        final nested = dataNode['items'] ??
            dataNode['products'] ??
            dataNode['productCardVMs'];
        if (nested is List) {
          return toMapList(nested);
        }
        final nestedSearch = dataNode['searchResult'];
        if (nestedSearch is Map<String, dynamic>) {
          final searchItems = nestedSearch['productCardVMs'] ??
              nestedSearch['items'] ??
              nestedSearch['products'];
          if (searchItems is List) {
            return toMapList(searchItems);
          }
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

  bool _isValidItem(Map<String, dynamic> data) {
    final id = data['id'] ?? data['_id'] ?? data['itemId'];
    final parsedId = id is num ? id.toInt() : int.tryParse('${id ?? ''}');
    final name = (data['name'] ?? data['productName'] ?? '').toString().trim();
    final sku = (data['sku'] ?? data['code'] ?? '').toString().trim();
    final hasMedia =
        (data['imageUrl']?.toString().trim().isNotEmpty ?? false) ||
            (data['imageMulti']?.toString().trim().isNotEmpty ?? false) ||
            (data['imageUrlMulti']?.toString().trim().isNotEmpty ?? false) ||
            (data['imagemulti']?.toString().trim().isNotEmpty ?? false) ||
            ((data['images'] is List) && (data['images'] as List).isNotEmpty);
    return (parsedId != null && parsedId > 0) ||
        name.isNotEmpty ||
        sku.isNotEmpty ||
        hasMedia;
  }
}
