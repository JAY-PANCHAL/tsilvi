import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final args = Get.arguments;
    if (args is String && args.trim().isNotEmpty) {
      if (controller.mobile.value.trim().isEmpty ||
          controller.mobile.value.trim() != args.trim()) {
        controller.mobile.value = args.trim();
      }
    }
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeSlide(
                index: 0,
                child: GlassContainer(
                  radius: 24,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the OTP sent to your mobile number.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'OTP',
                          prefixIcon: Icon(Icons.lock, color: Colors.white70),
                        ),
                        onChanged: (value) => controller.otp.value = value,
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => GlassButton(
                          label: 'Verify & Continue',
                          loading: controller.isLoading.value,
                          onTap: controller.verifyOtp,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: Get.back,
                        child: const Text(
                          'Edit mobile number',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
