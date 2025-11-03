import '../../domain/entities/admin_user.dart';

class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? storeName;
  final String? representativeName;
  final String? address;
  final String registrationDate;
  final String? lastActivityDate;
  final String? avatarUrl;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.storeName,
    this.representativeName,
    this.address,
    required this.registrationDate,
    this.lastActivityDate,
    this.avatarUrl,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      storeName: json['storeName'],
      representativeName: json['representativeName'],
      address: json['address'],
      registrationDate: json['registrationDate'] ?? '',
      lastActivityDate: json['lastActivityDate'],
      avatarUrl: json['avatarUrl'],
    );
  }

  AdminUser toEntity() {
    return AdminUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      status: status,
      storeName: storeName,
      representativeName: representativeName,
      address: address,
      registrationDate: DateTime.parse(registrationDate),
      lastActivityDate: lastActivityDate != null ? DateTime.parse(lastActivityDate!) : null,
      avatarUrl: avatarUrl,
    );
  }
}

class UserRoleModel {
  final String id;
  final String name;
  final String description;
  final int userCount;
  final List<String> permissions;

  UserRoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.userCount,
    required this.permissions,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      userCount: json['userCount'] ?? 0,
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  UserRole toEntity() {
    return UserRole(
      id: id,
      name: name,
      description: description,
      userCount: userCount,
      permissions: permissions,
    );
  }
}
