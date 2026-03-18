import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.name,
    required super.slug,
    required super.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString().trim().isNotEmpty == true
        ? json['name'].toString()
        : (json['title']?.toString() ??
            json['categoryName']?.toString() ??
            json['collectionName']?.toString() ??
            '');
    final url = json['url']?.toString();
    final urlCategory = _extractCategoryFromUrl(url);
    final slug = json['slug']?.toString() ??
        json['handle']?.toString() ??
        json['category']?.toString() ??
        json['code']?.toString() ??
        urlCategory ??
        _slugify(name);
    final image = json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        json['thumbnail']?.toString() ??
        (json['media'] is Map<String, dynamic>
            ? json['media']['url']?.toString()
            : null) ??
        '';
    return CategoryModel(
      name: name,
      slug: slug,
      imageUrl: image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'imageUrl': imageUrl,
    };
  }

  static String _slugify(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  static String? _extractCategoryFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final parsed = Uri.tryParse(url.startsWith('http')
        ? url
        : 'https://tsilivijewels.com$url');
    if (parsed == null) return null;
    final category = parsed.queryParameters['category'];
    if (category == null || category.isEmpty) return null;
    return _slugify(category);
  }
}
