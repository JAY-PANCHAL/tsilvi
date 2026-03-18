import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.mobile,
    required super.email,
    required super.businessName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString(),
      name: (json['fullName'] ?? json['name'] ?? '').toString(),
      mobile: (json['mobile'] ?? json['contact'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      businessName: (json['businessName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'businessName': businessName,
    };
  }
}
