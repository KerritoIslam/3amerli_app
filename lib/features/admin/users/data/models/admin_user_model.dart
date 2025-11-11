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
  final idRaw = json['id'] ?? json['userId'] ?? json['user_id'];
  final id = idRaw != null ? idRaw.toString() : '';
  // coerce phone to string safely
  final phoneRaw = json['phone'] ?? json['phoneNumber'] ?? json['phone_number'] ?? '';
  final phone = phoneRaw != null ? phoneRaw.toString() : '';
  // registration / last activity may be missing or in different formats
  final registrationDateRaw = json['registrationDate'] ?? json['createdAt'] ?? json['created_at'];
  final lastActivity = json['lastActivityDate'] ?? json['last_activity_date'] ?? json['lastActivity'];

    return AdminUserModel(
      id: id,
      name: json['name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: phone,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      storeName: json['storeName'] ?? json['store_name'],
      representativeName: json['representativeName'] ?? json['representative_name'],
      address: json['address'] ?? json['location'] ?? json['addressLine'],
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
      storeName: storeName,
      representativeName: representativeName,
      address: address,
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
