import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../core/utils/app_storage.dart';

class ApiService {
  final String baseUrl;
  static void Function(bool success, String message)? onMessage;
  static Future<void> Function()? onUnauthorized;
  static bool _handlingUnauthorized = false;
  final http.Client _client = http.Client();

  ApiService({this.baseUrl = 'https://tsilivijewels.com'});

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final token = await AppStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path,
      {Map<String, String>? query, bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final response = await _send(
      method: 'GET',
      uri: uri,
      headers: await _headers(auth: auth),
    );
    final decoded = _attachStatus(_decode(response), response.statusCode);
    _handleUnauthorized(response.statusCode);
    _notify(response.statusCode, decoded);
    return decoded;
  }

  Future<dynamic> post(String path,
      {Map<String, String>? query,
      Object? body,
      bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final response = await _send(
      method: 'POST',
      uri: uri,
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    final decoded = _attachStatus(_decode(response), response.statusCode);
    _handleUnauthorized(response.statusCode);
    _notify(response.statusCode, decoded);
    return decoded;
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _send(
      method: 'DELETE',
      uri: uri,
      headers: await _headers(auth: auth),
    );
    final decoded = _attachStatus(_decode(response), response.statusCode);
    _handleUnauthorized(response.statusCode);
    _notify(response.statusCode, decoded);
    return decoded;
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    debugPrint('[API][$method] $uri');
    debugPrint('[API][$method] headers=$headers');
    if (body != null) debugPrint('[API][$method] body=$body');
    final request = http.Request(method, uri);
    request.headers.addAll(headers);
    if (body != null) request.body = body;
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    debugPrint('[API][$method] ${response.statusCode} ${response.body}');
    return response;
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  dynamic _attachStatus(dynamic decoded, int status) {
    if (decoded is Map<String, dynamic>) {
      return {
        ...decoded,
        '_statusCode': status,
      };
    }
    return {
      '_statusCode': status,
      'message': decoded?.toString() ?? '',
    };
  }

  void _notify(int status, dynamic decoded) {
    final msg = _extractMessage(decoded);
    if (msg == null || msg.isEmpty) return;
    final success = _extractSuccess(decoded, status);
    if (onMessage != null) onMessage!(success, msg);
  }

  void _handleUnauthorized(int status) {
    if (status != 401 || _handlingUnauthorized) return;
    _handlingUnauthorized = true;
    Future.microtask(() async {
      try {
        await AppStorage.setToken(null);
        await AppStorage.setLoggedIn(false);
        if (onUnauthorized != null) {
          await onUnauthorized!();
        }
      } finally {
        Future.delayed(const Duration(seconds: 1), () {
          _handlingUnauthorized = false;
        });
      }
    });
  }

  bool _extractSuccess(dynamic data, int status) {
    if (data is Map<String, dynamic>) {
      final s = data['success'] ?? data['status'];
      final nested = data['data'];
      final s2 = nested is Map<String, dynamic>
          ? (nested['success'] ?? nested['status'])
          : null;
      final value = s ?? s2;
      if (value is bool) return value;
      if (value is num) return value == 1 || value == 200;
      if (value is String) {
        final v = value.toLowerCase();
        return v == 'true' || v == 'success' || v == 'ok';
      }
    }
    return status >= 200 && status < 300;
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['msg']?.toString() ??
          (data['data'] is Map<String, dynamic>
              ? (data['data']['message']?.toString() ??
                  data['data']['msg']?.toString())
              : null);
    }
    return null;
  }
}
