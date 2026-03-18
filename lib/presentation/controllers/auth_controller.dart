import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import '../../core/utils/app_storage.dart';
import 'cart_controller.dart';
import 'users_controller.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../../core/utils/glass_snackbar.dart';

class AuthController extends GetxController {
  final AuthRepository repository;

  AuthController(this.repository);

  final mobile = ''.obs;
  final otp = ''.obs;
  final isLoading = false.obs;

  Future<void> sendOtp() async {
    if (mobile.value.trim().length < 10) {
      showGlassSnackbar(
        message: 'Enter a valid mobile number',
        success: false,
      );
      return;
    }
    isLoading.value = true;
    try {
      final result = await repository.sendOtp(mobile.value.trim());
      debugPrint('sendOtp response: ${result.raw}');
      if (result.success) {
        Get.toNamed(
          AppRoutes.otp,
          arguments: mobile.value.trim(),
        );
      } else {
        showGlassSnackbar(
          message: result.message ?? 'Failed to send OTP',
          success: false,
        );
      }
    } catch (e) {
      showGlassSnackbar(message: 'Network error: $e', success: false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    isLoading.value = true;
    try {
      final result =
          await repository.verifyOtp(mobile.value.trim(), otp.value.trim());
      debugPrint('verifyOtp response: ${result.raw}');
      if (result.success) {
        await AppStorage.setLoggedIn(true);
        Get.find<CartController>().fetchCart();
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        showGlassSnackbar(
          message: result.message ?? 'Please enter the correct OTP',
          success: false,
        );
      }
    } catch (e) {
      showGlassSnackbar(message: 'Network error: $e', success: false);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: GlassContainer(
              radius: 22,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(Icons.logout, color: Colors.white70, size: 36),
                  const SizedBox(height: 10),
                  const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Are you sure you want to logout?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  GlassButton(
                    label: 'Cancel',
                    onTap: Get.back,
                  ),
                  const SizedBox(height: 8),
                  GlassButton(
                    label: 'Logout',
                    onTap: () {
                      Get.back();
                      mobile.value = '';
                      otp.value = '';
                      Get.find<CartController>().clear();
                      Get.find<UsersController>().selectedUser.value = null;
                      AppStorage.setLoggedIn(false);
                      Get.offAllNamed(AppRoutes.login);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
