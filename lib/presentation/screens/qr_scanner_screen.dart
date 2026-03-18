import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_colors.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/users_controller.dart';
import '../widgets/customer_required_dialog.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final skuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryController = Get.find<InventoryController>();
    final usersController = Get.find<UsersController>();
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'QR Scanner',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  radius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white24, width: 1.5),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Positioned(
                                top: 20 + (160 * _controller.value),
                                child: Container(
                                  height: 2,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent
                                            .withOpacity(0.6),
                                        blurRadius: 12,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const Icon(Icons.qr_code_scanner,
                              size: 64, color: Colors.white70),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: skuController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Enter SKU manually',
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassButton(
                        label: 'Simulate Scan',
                        onTap: () async {
                          if (!usersController.hasSelectedUser) {
                            await showCustomerRequiredDialog();
                            return;
                          }
                          final sku = skuController.text.trim().isNotEmpty
                              ? skuController.text.trim()
                              : _randomSku();
                          await inventoryController.scanAndAddSku(sku);
                          if (mounted) Get.back();
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mock scanner is active',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
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

  String _randomSku() {
    final random = Random();
    return 'SKU-${1000 + random.nextInt(40)}';
  }
}
