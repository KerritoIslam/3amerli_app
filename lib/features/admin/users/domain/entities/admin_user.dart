class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status; // 'Actif' or 'Suspendu'
  final String? storeName;
  final String? representativeName;
  final String? address;
  final DateTime registrationDate;
  final DateTime? lastActivityDate;
  final String? avatarUrl;

  AdminUser({
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
}

class UserRole {
  final String id;
  final String name;
  final String description;
  final int userCount;
  final List<String> permissions;

  UserRole({
    required this.id,
    required this.name,
    required this.description,
    required this.userCount,
    required this.permissions,
  });
}
