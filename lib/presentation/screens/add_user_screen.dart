import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_colors.dart';
import '../../domain/entities/user_entity.dart';
import '../../routes/app_routes.dart';
import '../controllers/users_controller.dart';
import '../../core/utils/toast.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final businessController = TextEditingController();
  final emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    businessController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersController = Get.find<UsersController>();
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Add New Customer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlassContainer(
                  radius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          prefixIcon:
                              Icon(Icons.person, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number *',
                          prefixIcon: Icon(Icons.phone, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: businessController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Business Name',
                          prefixIcon:
                              Icon(Icons.store_mall_directory_outlined,
                                  color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Email (optional)',
                          prefixIcon:
                              Icon(Icons.email_outlined, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GlassButton(
                        label:
                            _isSubmitting ? 'Creating...' : 'Create Customer',
                        onTap: () async {
                          if (_isSubmitting) return;
                          if (nameController.text.trim().isEmpty ||
                              mobileController.text.trim().isEmpty) {
                            showToast('Name and mobile number are required',
                                success: false);
                            return;
                          }
                          setState(() => _isSubmitting = true);
                          final user = UserEntity(
                            id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                            name: nameController.text.trim(),
                            mobile: mobileController.text.trim(),
                            email:
                                emailController.text.trim().isNotEmpty
                                    ? emailController.text.trim()
                                    : '${nameController.text.trim().split(' ').first.toLowerCase()}@tsilivi.com',
                            businessName: businessController.text.trim(),
                          );
                          try {
                            final created = await usersController.addUser(user);
                            usersController.selectUser(created);
                            if (Get.currentRoute != AppRoutes.inventory) {
                              Get.offNamed(AppRoutes.inventory);
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This uses the live API.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
