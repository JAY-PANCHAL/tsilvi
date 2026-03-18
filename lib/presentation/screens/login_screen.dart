import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_assets.dart';
import '../../core/utils/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
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
                      Center(
                        child: Image.asset(
                          AppAssets.logo,
                          height: 84,
                          width: 84,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to Tsilivi',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login with your mobile number to receive OTP',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone, color: Colors.white70),
                        ),
                        onChanged: (value) => controller.mobile.value = value,
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => GlassButton(
                          label: 'Send OTP',
                          loading: controller.isLoading.value,
                          onTap: controller.sendOtp,
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
