import '../entities/admin_user.dart';

abstract class AdminUsersRepository {
  Future<List<AdminUser>> getAllUsers({String? query, String? statusFilter});
  Future<AdminUser> getUserById(String userId);
  Future<AdminUser> updateUserRole(String userId, String newRole);
  Future<AdminUser> updateUserStatus(String userId, String newStatus);
  Future<void> deleteUser(String userId);
  Future<void> deleteMultipleUsers(List<String> userIds);
  Future<List<UserRole>> getRoles();
}
