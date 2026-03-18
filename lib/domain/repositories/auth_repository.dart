import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> sendOtp(String mobile);
  Future<AuthResponse> verifyOtp(String mobile, String otp);
}
