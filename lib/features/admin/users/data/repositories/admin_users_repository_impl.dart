import 'dart:convert';

import 'package:amerli_app/core/dio/api_service.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_users_repository.dart';
import '../models/admin_user_model.dart';

class AdminUsersRepositoryImpl implements AdminUsersRepository {
  final ApiService apiService;

  AdminUsersRepositoryImpl({required this.apiService});

  List _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    if (data is Map && data['items'] is List) return data['items'] as List;
    return [];
  }

  @override
  Future<List<AdminUser>> getAllUsers(
      {String? query,
      String? statusFilter,
      int page = 1,
      int limit = 20}) async {
    final qp = <String, dynamic>{};
    if (query != null && query.isNotEmpty) qp['search'] = query;
    if (statusFilter != null && statusFilter.isNotEmpty)
      qp['status'] = statusFilter;
    qp['page'] = page;
    qp['limit'] = limit;
    final resp = await apiService.get('/user/admin/all', queryParameters: qp);
    final list = _extractList(resp.data);

    try {
      // ignore: avoid_print
      print('[ADMIN USERS] extracted list length: ${list.length}');
      if (list.isNotEmpty) {
        // ignore: avoid_print
        print('[ADMIN USERS] first item preview: ${list.first}');
      }
    } catch (_) {}

    final results = <AdminUser>[];
    for (final e in list) {
      try {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          results.add(AdminUserModel.fromJson(m).toEntity());
        } else if (e is String) {
          try {
            final decoded = jsonDecode(e);
            if (decoded is Map)
              results.add(
                  AdminUserModel.fromJson(Map<String, dynamic>.from(decoded))
                      .toEntity());
          } catch (_) {
            // ignore malformed
            // ignore: avoid_print
            print('[ADMIN USERS] skipped malformed string entry');
          }
        } else {
          // ignore: avoid_print
          print(
              '[ADMIN USERS] skipped unsupported entry type: ${e.runtimeType}');
        }
      } catch (ex, st) {
        // ignore: avoid_print
        print('[ADMIN USERS] mapping error: $ex\n$st');
      }
    }

    return results;
  }

  @override
  Future<AdminUser> getUserById(String userId) async {
    // Use the admin-specific endpoint: /user/admin/{id}
    final resp = await apiService.get('/user/admin/$userId');
    if (resp.data is Map) {
      final m = Map<String, dynamic>.from(resp.data as Map);
      return AdminUserModel.fromJson(m).toEntity();
    }
    throw Exception('Unexpected user response');
  }

  @override
  Future<AdminUser> updateUserRole(String userId, String newRole) async {
    final resp =
        await apiService.post('/user/$userId/role', data: {'role': newRole});
    if (resp.data is Map)
      return AdminUserModel.fromJson(Map<String, dynamic>.from(resp.data))
          .toEntity();
    throw Exception('Unexpected update user role response');
  }

  @override
  Future<AdminUser> updateUserStatus(String userId, String newStatus) async {
    final resp = await apiService
        .post('/user/$userId/status', data: {'status': newStatus});
    if (resp.data is Map)
      return AdminUserModel.fromJson(Map<String, dynamic>.from(resp.data))
          .toEntity();
    throw Exception('Unexpected update user status response');
  }

  @override
  Future<void> deleteUser(String userId) async {
    // Use the admin-specific endpoint: /user/admin/{id}
    await apiService.delete('/user/admin/$userId');
  }

  @override
  Future<void> deleteMultipleUsers(List<String> userIds) async {
    // Convert string IDs to integers as required by the API
    final ids = userIds.map((id) => int.parse(id)).toList();

    // Use the Dio client directly to send DELETE with body (for users bulk delete)
    final response = await apiService.client.delete(
      '/user/admin/bulk',
      data: {
        'userIds': ids,
      },
    );

    // Check if the response indicates an error
    // The API returns success: false for errors even with 404 status
    if (response.statusCode != null && response.statusCode! >= 400) {
      throw Exception(
        response.data is Map && response.data['message'] != null
            ? response.data['message']
            : 'Delete failed',
      );
    }

    // Also check the success field if present
    if (response.data is Map && response.data['success'] == false) {
      throw Exception(response.data['message'] ?? 'Delete failed');
    }
  }

  @override
  Future<List<UserRole>> getRoles() async {
    final resp = await apiService.get('/user/roles');
    final list = _extractList(resp.data);
    return list
        .map<UserRole>((e) =>
            UserRoleModel.fromJson(Map<String, dynamic>.from(e as Map))
                .toEntity())
        .toList();
  }

  @override
  Future<List<AdminUser>> getBlacklistedUsers(
      {int page = 1, int limit = 20}) async {
    final resp = await apiService.get('/user/black-list',
        queryParameters: {'page': page, 'limit': limit});
    final list = _extractList(resp.data);

    final results = <AdminUser>[];
    for (final e in list) {
      try {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          results.add(AdminUserModel.fromJson(m).toEntity());
        }
      } catch (ex) {
        // ignore: avoid_print
        print('[ADMIN USERS] blacklist mapping error: $ex');
      }
    }
    return results;
  }

  @override
  Future<void> addToBlacklist(String userId) async {
    await apiService.post('/user/black-list/$userId');
  }

  @override
  Future<void> restoreFromBlacklist(String userId) async {
    await apiService.post('/user/black-list/restore/$userId');
  }
}
