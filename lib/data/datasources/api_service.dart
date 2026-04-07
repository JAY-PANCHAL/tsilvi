import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/app_storage.dart';

class ApiService {
  final String baseUrl;
  static void Function(bool success, String message)? onMessage;
  static Future<void> Function()? onUnauthorized;
  static bool _handlingUnauthorized = false;
  final http.Client _client = _buildClient();

  /// Creates an IOClient with a custom HttpClient so that SSL handshakes
  /// work correctly in AOT/release mode on Android and iOS.
  /// The badCertificateCallback allows the app to connect even if the server
  /// certificate is self-signed or has a chain issue.
  static http.Client _buildClient() {
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        // Allow connections to our own API domain regardless of cert issues
        return host.contains('tsilivijewels.com');
      };
    return IOClient(httpClient);
  }

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
    Future<http.Response> doSend(Uri target) async {
      debugPrint('[API][$method] $target');
      debugPrint('[API][$method] headers=$headers');
      if (body != null) debugPrint('[API][$method] body=$body');
      final request = http.Request(method, target);
      request.headers.addAll(headers);
      if (body != null) request.body = body;
      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);
      debugPrint('[API][$method] ${response.statusCode} ${response.body}');
      return response;
    }

    try {
      return await doSend(uri);
    } on SocketException catch (e) {
      final isHostLookup = e.message.toLowerCase().contains('failed host lookup');
      final hasWww = uri.host.toLowerCase().startsWith('www.');
      if (isHostLookup && !hasWww) {
        final retryUri = uri.replace(host: 'www.${uri.host}');
        debugPrint(
            '[API][$method] host lookup failed for ${uri.host}, retrying with ${retryUri.host}');
        return doSend(retryUri);
      }
      rethrow;
    } on TimeoutException {
      final hasWww = uri.host.toLowerCase().startsWith('www.');
      if (!hasWww) {
        final retryUri = uri.replace(host: 'www.${uri.host}');
        debugPrint(
            '[API][$method] timeout for ${uri.host}, retrying with ${retryUri.host}');
        try {
          return await doSend(retryUri);
        } on TimeoutException {
          throw const SocketException(
              'Request timed out. Please check connection.');
        }
      }
      throw const SocketException('Request timed out. Please check connection.');
    }
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
