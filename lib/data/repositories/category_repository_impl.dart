import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/api_service.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final ApiService api;

  CategoryRepositoryImpl(this.api);

  @override
  Future<List<CategoryEntity>> fetchCollections() async {
    final data = await api.get('/collections', auth: false);
    final list = _extractList(data);
    final models = list.map((e) => CategoryModel.fromJson(e)).toList();
    return _dedupe(models);
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final dataNode = data['data'];
      if (dataNode is Map<String, dynamic>) {
        final nested = dataNode['categories'] ?? dataNode['collections'];
        if (nested is List) {
          return nested.whereType<Map<String, dynamic>>().toList();
        }
      }
      final list =
          data['collections'] ?? data['categories'] ?? data['result'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
      if (list is Map<String, dynamic>) {
        return [list];
      }
    }
    return [];
  }

  List<CategoryEntity> _dedupe(List<CategoryModel> models) {
    final map = <String, CategoryModel>{};
    for (final item in models) {
      final key = item.slug.isNotEmpty ? item.slug : item.name.toLowerCase();
      if (!map.containsKey(key)) {
        map[key] = item;
      } else {
        final existing = map[key]!;
        if (existing.imageUrl.isEmpty && item.imageUrl.isNotEmpty) {
          map[key] = item;
        }
      }
    }
    return map.values.toList();
  }
}
