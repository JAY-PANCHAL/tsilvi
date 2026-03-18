class AuthResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? raw;

  AuthResponse({required this.success, this.message, this.raw});
}
