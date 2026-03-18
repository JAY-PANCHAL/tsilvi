import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/app_colors.dart';
import '../../routes/app_routes.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/gradient_background.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = Get.arguments as String? ?? 'ORD-0000';
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassContainer(
                radius: 24,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.6, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: const Icon(Icons.check_circle,
                          color: Colors.white, size: 64),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Order Placed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (orderId.isNotEmpty) ...[
                      Text(
                        'Order ID: $orderId',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final max = constraints.maxWidth > 520
                              ? 520.0
                              : constraints.maxWidth;
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: GlassIconButton(
                              icon: Icons.share_outlined,
                              label: 'Share Order ID',
                              onTap: () => Share.share('Order ID: $orderId'),
                              fullWidth: true,
                              maxWidth: max,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    GlassButton(
                      label: 'Back to Dashboard',
                      onTap: () => Get.offAllNamed(AppRoutes.dashboard),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.orders),
                      child: const Text(
                        'View Order History',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
