import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/category_model.dart';
import '../../domain/entities/category_entity.dart';

class AppStorage {
  static const _keyLoggedIn = 'logged_in';
  static const _keyToken = 'access_token';
  static const _keyCategories = 'categories';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    if (!loggedIn) return false;
    final token = prefs.getString(_keyToken);
    return token != null && token.trim().isNotEmpty;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
  }

  static Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_keyToken);
    } else {
      await prefs.setString(_keyToken, token);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> setCategories(List<CategoryEntity> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final data = categories
        .map((e) => CategoryModel(
              name: e.name,
              slug: e.slug,
              imageUrl: e.imageUrl,
            ).toJson())
        .toList();
    await prefs.setString(_keyCategories, jsonEncode(data));
  }

  static Future<List<CategoryEntity>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCategories);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryModel.fromJson(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
