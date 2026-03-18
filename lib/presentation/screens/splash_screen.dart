import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_storage.dart';
import '../../core/utils/toast.dart';
import '../../domain/repositories/category_repository.dart';
import '../../routes/app_routes.dart';
import '../widgets/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final repo = Get.find<CategoryRepository>();
      final categories = await repo.fetchCollections();
      if (categories.isNotEmpty) {
        await AppStorage.setCategories(categories);
      }
    } catch (e) {
      showToast('Unable to load categories', success: false);
    }
    final loggedIn = await AppStorage.isLoggedIn();
    Get.offAllNamed(loggedIn ? AppRoutes.dashboard : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading collections...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
