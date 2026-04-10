import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import 'glass_button.dart';
import 'glass_container.dart';

Future<void> showCustomerRequiredDialog() async {
  await Get.bottomSheet(
    SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: GlassContainer(
          radius: 24,
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 12),
              const Icon(Icons.person_outline,
                  color: Colors.white70, size: 42),
              const SizedBox(height: 10),
              const Text(
                'Select Customer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cart belongs to a customer. Create a new customer or pick an existing one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              GlassButton(
                label: 'Add New Customer',
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoutes.addUser);
                },
              ),
              const SizedBox(height: 10),
              GlassButton(
                label: 'Choose Existing',
                onTap: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.existingUsers,
                    arguments: {'allowSelection': true},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
