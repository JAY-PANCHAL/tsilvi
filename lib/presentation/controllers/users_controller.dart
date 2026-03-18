import 'package:get/get.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import 'cart_controller.dart';

class UsersController extends GetxController {
  final UserRepository repository;

  UsersController(this.repository);

  final users = <UserEntity>[].obs;
  final isLoading = false.obs;
  final query = ''.obs;
  final selectedUser = Rxn<UserEntity>();

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    final data = await repository.fetchUsers(query: query.value);
    users.assignAll(data);
    isLoading.value = false;
  }

  void updateQuery(String value) {
    query.value = value;
    fetchUsers();
  }

  Future<UserEntity> addUser(UserEntity user) async {
    final created = await repository.addUser(user);
    users.insert(0, created);
    return created;
  }

  void selectUser(UserEntity user) {
    final prev = selectedUser.value;
    selectedUser.value = user;
    if (prev == null || prev.id != user.id) {
      Get.find<CartController>().clear();
    }
  }

  bool get hasSelectedUser => selectedUser.value != null;
}
