import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_colors.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/users_controller.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_background.dart';
import '../widgets/shimmer_loader.dart';

class ExistingUsersScreen extends StatefulWidget {
  const ExistingUsersScreen({super.key});

  @override
  State<ExistingUsersScreen> createState() => _ExistingUsersScreenState();
}

class _ExistingUsersScreenState extends State<ExistingUsersScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<UsersController>().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final usersController = Get.find<UsersController>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Existing Customers',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search by name, mobile, email',
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                  ),
                  onChanged: usersController.updateQuery,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(
                  () {
                    if (usersController.isLoading.value) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: 6,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (_, __) => const ShimmerListTile(),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: usersController.users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final user = usersController.users[index];
                        return _UserCard(
                          user: user,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserEntity user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 20,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.12),
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user.businessName.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    user.businessName,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  user.mobile,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
              ),
            ),
        ],
      ),
    );
  }
}
