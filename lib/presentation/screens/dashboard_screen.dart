import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_assets.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pressable_scale.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final columns = Responsive.gridCount(context, mobile: 2, tablet: 3);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      AppAssets.logo,
                      height: 34,
                      width: 34,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tsilivi Sales',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: authController.logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Quick actions & insights',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: columns == 1 ? 1.4 : 1.0,
                    children: [
                      FadeSlide(
                        index: 0,
                        child: _ActionCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Book Orders',
                          subtitle: 'Browse products',
                          onTap: () => Get.toNamed(AppRoutes.inventory),
                        ),
                      ),
                      FadeSlide(
                        index: 1,
                        child: _ActionCard(
                          icon: Icons.person_add_alt_1,
                          title: 'Add New Customer',
                          subtitle: 'Create customer',
                          onTap: () => Get.toNamed(AppRoutes.addUser),
                        ),
                      ),
                      FadeSlide(
                        index: 2,
                        child: _ActionCard(
                          icon: Icons.people_alt_outlined,
                          title: 'Customers List',
                          subtitle: 'Select customer',
                          onTap: () => Get.toNamed(AppRoutes.existingUsers),
                        ),
                      ),
                      FadeSlide(
                        index: 3,
                        child: _ActionCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Orders Hstory',
                          subtitle: 'Track orders',
                          onTap: () => Get.toNamed(AppRoutes.orders),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        radius: 22,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withOpacity(0.12),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
