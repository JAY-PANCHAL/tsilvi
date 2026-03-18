import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_assets.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/fade_slide.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';
import '../widgets/pressable_scale.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryController = Get.find<InventoryController>();
    final authController = Get.find<AuthController>();
    final columns = Responsive.gridCount(context, mobile: 1, tablet: 2);
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
                        'Dashboard',
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
                    const CartIconButton(),
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
                    childAspectRatio: columns == 1 ? 2.4 : 2.2,
                    children: [
                      FadeSlide(
                        index: 0,
                        child: _ActionCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Inventory',
                          subtitle: 'Browse products',
                          onTap: () => Get.toNamed(AppRoutes.inventory),
                        ),
                      ),
                      FadeSlide(
                        index: 1,
                        child: Obx(
                          () => _InfoCard(
                            icon: Icons.layers_outlined,
                            title: 'Total Inventory',
                            value:
                                '${inventoryController.items.length} items',
                          ),
                        ),
                      ),
                      FadeSlide(
                        index: 2,
                        child: _ActionCard(
                          icon: Icons.person_add_alt_1,
                          title: 'Add New User',
                          subtitle: 'Create customer',
                          onTap: () => Get.toNamed(AppRoutes.addUser),
                        ),
                      ),
                      FadeSlide(
                        index: 3,
                        child: _ActionCard(
                          icon: Icons.people_alt_outlined,
                          title: 'Existing Users',
                          subtitle: 'Select customer',
                          onTap: () => Get.toNamed(AppRoutes.existingUsers),
                        ),
                      ),
                      FadeSlide(
                        index: 4,
                        child: _ActionCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Orders History',
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.12),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 22,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.12),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
