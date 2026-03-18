import 'package:get/get.dart';

import '../../data/datasources/api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/cart_controller.dart';
import '../../presentation/controllers/dashboard_controller.dart';
import '../../presentation/controllers/inventory_controller.dart';
import '../../presentation/controllers/orders_controller.dart';
import '../../presentation/controllers/users_controller.dart';
import '../utils/glass_snackbar.dart';

void registerDependencies() {
  final apiService = ApiService();
  ApiService.onMessage = (success, message) {
    showGlassSnackbar(message: message, success: success);
  };
  Get.lazyPut(() => apiService, fenix: true);

  Get.lazyPut<AuthRepositoryImpl>(() => AuthRepositoryImpl(Get.find()),
      fenix: true);
  Get.lazyPut<CartRepositoryImpl>(() => CartRepositoryImpl(Get.find()),
      fenix: true);
  Get.lazyPut<CategoryRepositoryImpl>(
      () => CategoryRepositoryImpl(Get.find()),
      fenix: true);
  Get.lazyPut<InventoryRepositoryImpl>(
      () => InventoryRepositoryImpl(Get.find()),
      fenix: true);
  Get.lazyPut<UserRepositoryImpl>(() => UserRepositoryImpl(Get.find()),
      fenix: true);
  Get.lazyPut<OrderRepositoryImpl>(() => OrderRepositoryImpl(Get.find()),
      fenix: true);

  Get.lazyPut<AuthRepository>(() => Get.find<AuthRepositoryImpl>(),
      fenix: true);
  Get.lazyPut<CartRepository>(() => Get.find<CartRepositoryImpl>(),
      fenix: true);
  Get.lazyPut<CategoryRepository>(() => Get.find<CategoryRepositoryImpl>(),
      fenix: true);
  Get.lazyPut<InventoryRepository>(() => Get.find<InventoryRepositoryImpl>(),
      fenix: true);
  Get.lazyPut<UserRepository>(() => Get.find<UserRepositoryImpl>(),
      fenix: true);
  Get.lazyPut<OrderRepository>(() => Get.find<OrderRepositoryImpl>(),
      fenix: true);

  Get.lazyPut(() => AuthController(Get.find()), fenix: true);
  Get.lazyPut(() => InventoryController(Get.find()), fenix: true);
  Get.lazyPut(() => CartController(Get.find()), fenix: true);
  Get.lazyPut(() => UsersController(Get.find()), fenix: true);
  Get.lazyPut(() => OrdersController(Get.find()), fenix: true);
  Get.lazyPut(() => DashboardController(), fenix: true);
}
