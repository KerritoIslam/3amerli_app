import '../../domain/entities/admin_user.dart';

class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final bool isActive;
  final String? storeName;
  final String? representativeName;
  final String? address;
  final String? supermarketName;
  final List<UserAddressModel>? addresses;
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

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
  final idRaw = json['id'] ?? json['userId'] ?? json['user_id'];
  final id = idRaw != null ? idRaw.toString() : '';
  // coerce phone to string safely
  final phoneRaw = json['phone'] ?? json['phoneNumber'] ?? json['phone_number'] ?? '';
  final phone = phoneRaw != null ? phoneRaw.toString() : '';
  // registration / last activity may be missing or in different formats
  final registrationDateRaw = json['registrationDate'] ?? json['createdAt'] ?? json['created_at'];
  final lastActivity = json['lastActivityDate'] ?? json['last_activity_date'] ?? json['lastActivity'];

  // Parse addresses list if present
  List<UserAddressModel>? addresses;
  if (json['addresses'] != null && json['addresses'] is List) {
    addresses = (json['addresses'] as List)
        .map((addr) => UserAddressModel.fromJson(Map<String, dynamic>.from(addr)))
        .toList();
  }

    return AdminUserModel(
      id: id,
      name: json['name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: phone,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      isActive: json['isActive'] ?? true,
      storeName: json['storeName'] ?? json['store_name'],
      representativeName: json['representativeName'] ?? json['representative_name'],
      address: json['address'] ?? json['location'] ?? json['addressLine'],
      supermarketName: json['supermarketName'] ?? json['supermarket_name'],
      addresses: addresses,
      registrationDate: registrationDateRaw?.toString() ?? '',
      lastActivityDate: lastActivity?.toString(),
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
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
      isActive: isActive,
      storeName: storeName,
      representativeName: representativeName,
      address: address,
      supermarketName: supermarketName,
      addresses: addresses?.map((addr) => addr.toEntity()).toList(),
      // Parse registrationDate defensively; backend may omit it or use unexpected formats
      registrationDate: _parseDateSafe(registrationDate) ?? DateTime.fromMillisecondsSinceEpoch(0),
      lastActivityDate: lastActivityDate != null ? _parseDateSafe(lastActivityDate!) : null,
      avatarUrl: avatarUrl,
    );
  }

  static DateTime? _parseDateSafe(String? raw) {
    if (raw == null) return null;
    if (raw.isEmpty) return null;
    // try ISO parse
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;
    // try parsing as int (epoch millis / seconds)
    final asInt = int.tryParse(raw);
    if (asInt != null) {
      // Heuristic: if value looks like seconds (10 digits) convert to ms
      if (raw.length <= 10) return DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
      return DateTime.fromMillisecondsSinceEpoch(asInt);
    }
    return null;
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

class UserAddressModel {
  final String id;
  final String street;
  final String city;
  final String district;
  final String createdAt;

  UserAddressModel({
    required this.id,
    required this.street,
    required this.city,
    required this.district,
    required this.createdAt,
  });

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      id: json['id']?.toString() ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  UserAddress toEntity() {
    return UserAddress(
      id: id,
      street: street,
      city: city,
      district: district,
      createdAt: AdminUserModel._parseDateSafe(createdAt) ?? DateTime.now(),
    );
  }
}
