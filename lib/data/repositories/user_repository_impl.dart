import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/api_service.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService api;

  UserRepositoryImpl(this.api);

  @override
  Future<List<UserEntity>> fetchUsers({String query = ''}) {
    final params = <String, String>{};
    if (query.isNotEmpty) params['search'] = query;
    return api.get('/sales-users', query: params).then((data) {
      final list = _extractList(data);
      return list.map((e) => UserModel.fromJson(e)).toList();
    });
  }

  @override
  Future<UserEntity> addUser(UserEntity user) {
    final body = {
      'fullName': user.name,
      'mobile': user.mobile,
      'email': user.email,
      'businessName': user.businessName,
      'userType': 1,
      'createdBy': 1,
    };
    return api.post('/sales-users', body: body).then((data) {
      if (data is Map<String, dynamic>) {
        final node = (data['data'] is Map<String, dynamic>)
            ? data['data'] as Map<String, dynamic>
            : data;
        return UserModel.fromJson(node);
      }
      return UserModel(
        id: user.id,
        name: user.name,
        mobile: user.mobile,
        email: user.email,
        businessName: user.businessName,
      );
    });
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['items'] ?? data['users'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }
}
