import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/api_service.dart';
import '../../core/utils/app_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService api;

  AuthRepositoryImpl(this.api);

  @override
  Future<AuthResponse> sendOtp(String mobile) async {
    final data = await api.post('/auth/send-otp',
        body: {'contact': mobile}, auth: false);
    final message = _extractMessage(data);
    final success = _extractSuccess(data);
    return AuthResponse(
      success: success,
      message: message,
      raw: data is Map<String, dynamic> ? data : null,
    );
  }

  @override
  Future<AuthResponse> verifyOtp(String mobile, String otp) async {
    final data = await api.post('/auth/verify-otp',
        body: {'contact': mobile, 'otp': otp}, auth: false);
    final token = _extractToken(data);
    final message = _extractMessage(data);
    if (token != null && token.isNotEmpty) {
      await AppStorage.setToken(token);
      return AuthResponse(
        success: true,
        message: message,
        raw: data is Map<String, dynamic> ? data : null,
      );
    }
    return AuthResponse(
      success: false,
      message: message,
      raw: data is Map<String, dynamic> ? data : null,
    );
  }

  String? _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['accessToken']?.toString() ??
          data['token']?.toString() ??
          (data['data'] is Map<String, dynamic>
              ? (data['data']['accessToken']?.toString() ??
                  data['data']['token']?.toString())
              : null);
    }
    return null;
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

  bool _extractSuccess(dynamic data) {
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
      final code = data['_statusCode'];
      if (code is int) return code >= 200 && code < 300;
    }
    return false;
  }
}
