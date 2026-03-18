import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> fetchUsers({String query});
  Future<UserEntity> addUser(UserEntity user);
}
