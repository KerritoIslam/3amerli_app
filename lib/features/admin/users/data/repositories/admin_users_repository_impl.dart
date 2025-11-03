import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_users_repository.dart';
import '../models/admin_user_model.dart';

class AdminUsersRepositoryImpl implements AdminUsersRepository {
  // Mock data storage
  final List<AdminUserModel> _mockUsers = [
    AdminUserModel(
      id: 'USR001',
      name: 'Ahmed Benali',
      email: 'ahmed.benali@email.com',
      phone: '0555123456',
      role: 'Supérette',
      status: 'Actif',
      storeName: 'Supérette El Baraka',
      representativeName: 'Ahmed Benali',
      address: '12 Rue des Jasmine, Alger',
      registrationDate: DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
      lastActivityDate: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    ),
    AdminUserModel(
      id: 'USR002',
      name: 'Fatima Meziane',
      email: 'fatima.m@email.com',
      phone: '0666234567',
      role: 'Supérette',
      status: 'Actif',
      storeName: 'Supérette Nour',
      representativeName: 'Fatima Meziane',
      address: '45 Avenue Mohamed V, Oran',
      registrationDate: DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      lastActivityDate: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    ),
    AdminUserModel(
      id: 'USR003',
      name: 'Karim Djebbar',
      email: 'karim.djebbar@email.com',
      phone: '0777345678',
      role: 'Admin',
      status: 'Actif',
      registrationDate: DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
      lastActivityDate: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
    ),
    AdminUserModel(
      id: 'USR004',
      name: 'Amina Hamdi',
      email: 'amina.hamdi@email.com',
      phone: '0555456789',
      role: 'Supérette',
      status: 'Suspendu',
      storeName: 'Supérette Hamdi',
      representativeName: 'Amina Hamdi',
      address: '8 Rue des Frères Bouadou, Annaba',
      registrationDate: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      lastActivityDate: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    ),
    AdminUserModel(
      id: 'USR005',
      name: 'Youcef Larbi',
      email: 'youcef.l@email.com',
      phone: '0666567890',
      role: 'Grossiste',
      status: 'Actif',
      storeName: 'Grossiste Larbi & Fils',
      representativeName: 'Youcef Larbi',
      address: '31 Rue Hassiba Ben Bouali, Blida',
      registrationDate: DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
      lastActivityDate: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    ),
    AdminUserModel(
      id: 'USR006',
      name: 'Samia Bouzid',
      email: 'samia.bouzid@email.com',
      phone: '0777678901',
      role: 'Supérette',
      status: 'Suspendu',
      storeName: 'Supérette Bouzid',
      representativeName: 'Samia Bouzid',
      address: '12 Cité des Jardins, Tlemcen',
      registrationDate: DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
      lastActivityDate: DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
    ),
    AdminUserModel(
      id: 'USR007',
      name: 'Rachid Khelil',
      email: 'rachid.k@email.com',
      phone: '0555789012',
      role: 'Livreur',
      status: 'Actif',
      registrationDate: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      lastActivityDate: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    ),
  ];

  final List<UserRoleModel> _mockRoles = [
    UserRoleModel(
      id: 'ROLE001',
      name: 'Admin',
      description: 'Administrateur système',
      userCount: 1,
      permissions: ['all'],
    ),
    UserRoleModel(
      id: 'ROLE002',
      name: 'Supérette',
      description: 'Gérant de supérette',
      userCount: 4,
      permissions: ['order', 'view_products'],
    ),
    UserRoleModel(
      id: 'ROLE003',
      name: 'Grossiste',
      description: 'Grossiste distributeur',
      userCount: 1,
      permissions: ['bulk_order', 'view_products'],
    ),
    UserRoleModel(
      id: 'ROLE004',
      name: 'Livreur',
      description: 'Livreur',
      userCount: 1,
      permissions: ['view_deliveries', 'update_delivery_status'],
    ),
  ];

  @override
  Future<List<AdminUser>> getAllUsers({String? query, String? statusFilter}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    List<AdminUserModel> filteredUsers = _mockUsers;

    // Apply status filter
    if (statusFilter != null && statusFilter.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) => user.status == statusFilter).toList();
    }

    // Apply search query
    if (query != null && query.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        return user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()) ||
            user.phone.contains(query) ||
            (user.storeName?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    }

    return filteredUsers.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AdminUser> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final userModel = _mockUsers.firstWhere(
      (user) => user.id == userId,
      orElse: () => _mockUsers.first,
    );

    return userModel.toEntity();
  }

  @override
  Future<AdminUser> updateUserRole(String userId, String newRole) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockUsers.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _mockUsers[index] = AdminUserModel(
        id: _mockUsers[index].id,
        name: _mockUsers[index].name,
        email: _mockUsers[index].email,
        phone: _mockUsers[index].phone,
        role: newRole,
        status: _mockUsers[index].status,
        storeName: _mockUsers[index].storeName,
        representativeName: _mockUsers[index].representativeName,
        address: _mockUsers[index].address,
        registrationDate: _mockUsers[index].registrationDate,
        lastActivityDate: _mockUsers[index].lastActivityDate,
        avatarUrl: _mockUsers[index].avatarUrl,
      );
      return _mockUsers[index].toEntity();
    }

    throw Exception('User not found');
  }

  @override
  Future<AdminUser> updateUserStatus(String userId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockUsers.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _mockUsers[index] = AdminUserModel(
        id: _mockUsers[index].id,
        name: _mockUsers[index].name,
        email: _mockUsers[index].email,
        phone: _mockUsers[index].phone,
        role: _mockUsers[index].role,
        status: newStatus,
        storeName: _mockUsers[index].storeName,
        representativeName: _mockUsers[index].representativeName,
        address: _mockUsers[index].address,
        registrationDate: _mockUsers[index].registrationDate,
        lastActivityDate: _mockUsers[index].lastActivityDate,
        avatarUrl: _mockUsers[index].avatarUrl,
      );
      return _mockUsers[index].toEntity();
    }

    throw Exception('User not found');
  }

  @override
  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockUsers.removeWhere((user) => user.id == userId);
  }

  @override
  Future<void> deleteMultipleUsers(List<String> userIds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockUsers.removeWhere((user) => userIds.contains(user.id));
  }

  @override
  Future<List<UserRole>> getRoles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockRoles.map((m) => m.toEntity()).toList();
  }
}
