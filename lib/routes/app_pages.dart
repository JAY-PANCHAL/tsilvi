import 'package:get/get.dart';

import '../core/utils/di.dart';
import '../presentation/screens/add_user_screen.dart';
import '../presentation/screens/cart_screen.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/existing_users_screen.dart';
import '../presentation/screens/inventory_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/order_history_screen.dart';
import '../presentation/screens/order_detail_screen.dart';
import '../presentation/screens/order_success_screen.dart';
import '../presentation/screens/otp_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/qr_scanner_screen.dart';
import '../presentation/screens/gallery_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.inventory,
      page: () => const InventoryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addUser,
      page: () => const AddUserScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.existingUsers,
      page: () => const ExistingUsersScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderHistoryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.success,
      page: () => const OrderSuccessScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.qrScanner,
      page: () => const QrScannerScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.gallery,
      page: () => const GalleryScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    registerDependencies();
  }
}
