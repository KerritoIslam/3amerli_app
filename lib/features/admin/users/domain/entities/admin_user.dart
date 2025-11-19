class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status; // 'Actif' or 'Suspendu'
  final bool isActive; // Suspension status from backend
  final String? storeName;
  final String? representativeName;
  final String? address;
  final String? supermarketName; // New field for supermarket name
  final List<UserAddress>? addresses; // New field for addresses list
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
    required this.isActive,
    this.storeName,
    this.representativeName,
    this.address,
    this.supermarketName,
    this.addresses,
    required this.registrationDate,
    this.lastActivityDate,
    this.avatarUrl,
  });
}

class UserAddress {
  final String id;
  final String street;
  final String city;
  final String district;
  final DateTime createdAt;

  UserAddress({
    required this.id,
    required this.street,
    required this.city,
    required this.district,
    required this.createdAt,
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
