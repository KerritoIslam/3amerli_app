import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> fetchProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> addressData);
  Future<List<Map<String, dynamic>>> getAddresses();
  Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> addressData);
  Future<void> deleteAddress(int id);
  Future<String> uploadProfilePicture(String filePath);
  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSourceImpl({required this.apiService});

  bool _isSuccess(int? status) => status != null && status >= 200 && status < 300;

  @override
  Future<UserModel> fetchProfile() async {
    try {
      final resp = await apiService.get('/user/me');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch profile';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching profile';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error fetchProfile - status: $status, serverResponse: $serverResp', name: 'ProfileRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> payload) async {
    try {
      final resp = await apiService.put('/user/me', data: payload);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to update profile';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while updating profile';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error updateProfile - status: $status, serverResponse: $serverResp', name: 'ProfileRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }

  @override
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> addressData) async {
    try {
      final resp = await apiService.post('/user/address', data: addressData);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return Map<String, dynamic>.from(resp.data as Map);
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to create address';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while creating address';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error createAddress - status: $status, serverResponse: $serverResp', name: 'ProfileRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final resp = await apiService.get('/user/address');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data as List<dynamic>;
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch addresses';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching addresses';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error getAddresses - status: $status, serverResponse: $serverResp', name: 'ProfileRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
  }

  @override
  Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> addressData) async {
    try {
      final resp = await apiService.put('/user/address/$id', data: addressData);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return Map<String, dynamic>.from(resp.data as Map);
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to update address';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while updating address';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error updateAddress - status: $status, serverResponse: $serverResp', name: 'ProfileRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
  }

  @override
  Future<void> deleteAddress(int id) async {
    try {
      final resp = await apiService.delete('/user/address/$id');
      if (!_isSuccess(resp.statusCode)) {
        final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to delete address';
        throw ApiException(msg, statusCode: resp.statusCode);
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while deleting address';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error deleteAddress - status: $status, serverResponse: $serverResp', name: 'ProfileRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
  }

  @override
  Future<String> uploadProfilePicture(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'picture': await MultipartFile.fromFile(filePath),
      });
      final resp = await apiService.client.patch('/user/me/picture', data: formData);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        return data['profilePic']?.toString() ?? '';
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to upload profile picture';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while uploading profile picture';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error uploadProfilePicture - status: $status, serverResponse: $serverResp', name: 'ProfileRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final resp = await apiService.delete('/user/me');
      if (!_isSuccess(resp.statusCode)) {
        final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to delete account';
        throw ApiException(msg, statusCode: resp.statusCode);
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while deleting account';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error deleteAccount - status: $status, serverResponse: $serverResp', name: 'ProfileRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
  }
}
