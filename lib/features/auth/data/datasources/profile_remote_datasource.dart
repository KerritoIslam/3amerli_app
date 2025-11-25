import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/core/network/error_message_extractor.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> fetchProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> addressData);
  Future<List<Map<String, dynamic>>> getAddresses();
  Future<Map<String, dynamic>> updateAddress(
      int id, Map<String, dynamic> addressData);
  Future<void> deleteAddress(int id);
  Future<String> uploadProfilePicture(String filePath);
  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSourceImpl({required this.apiService});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  @override
  Future<UserModel> fetchProfile() async {
    try {
      // Debug: log that we're starting the request
      // ignore: avoid_print
      print('[profile_remote] fetchProfile -> GET /user/me');
      final resp = await apiService.get('/user/me');
      // Debug: log response status and (small) payload indicator
      // ignore: avoid_print
      print(
          '[profile_remote] resp status: ${resp.statusCode}, dataType: ${resp.data.runtimeType}');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        // Debug: log the returned JSON keys (avoid dumping large payloads)
        try {
          if (resp.data is Map) {
            // ignore: avoid_print
            print(
                '[profile_remote] resp keys: ${(resp.data as Map).keys.toList()}');
          }
        } catch (_) {}
        return UserModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error fetchProfile - status: $status, serverResponse: $serverResp',
          name: 'ProfileRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      // Also print for quick debugging in dev
      // ignore: avoid_print

      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> payload) async {
    try {
      final resp = await apiService.put('/user/me', data: payload);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error updateProfile - status: $status, serverResponse: $serverResp',
          name: 'ProfileRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  @override
  Future<Map<String, dynamic>> createAddress(
      Map<String, dynamic> addressData) async {
    try {
      final resp = await apiService.post('/user/address', data: addressData);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return Map<String, dynamic>.from(resp.data as Map);
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error createAddress - status: $status, serverResponse: $serverResp',
          name: 'ProfileRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
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
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error getAddresses - status: $status, serverResponse: $serverResp',
          name: 'ProfileRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  @override
  Future<Map<String, dynamic>> updateAddress(
      int id, Map<String, dynamic> addressData) async {
    try {
      final resp = await apiService.put('/user/address/$id', data: addressData);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return Map<String, dynamic>.from(resp.data as Map);
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error updateAddress - status: $status, serverResponse: $serverResp',
          name: 'ProfileRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  @override
  Future<void> deleteAddress(int id) async {
    try {
      final resp = await apiService.delete('/user/address/$id');
      if (!_isSuccess(resp.statusCode)) {
        throw ApiException(
            extractErrorMessage(resp.data, defaultMessage: "network error"),
            statusCode: resp.statusCode,
            serverResponse: resp.data);
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error deleteAddress - status: $status, serverResponse: $serverResp',
          name: 'ProfileRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  @override
  Future<String> uploadProfilePicture(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'picture': await MultipartFile.fromFile(filePath),
      });
      final resp =
          await apiService.client.patch('/user/me/picture', data: formData);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        return data['profilePic']?.toString() ?? '';
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error uploadProfilePicture - status: $status, serverResponse: $serverResp',
          name: 'ProfileRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final resp = await apiService.delete('/user/me');
      if (!_isSuccess(resp.statusCode)) {
        throw ApiException(
            extractErrorMessage(resp.data, defaultMessage: "network error"),
            statusCode: resp.statusCode,
            serverResponse: resp.data);
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error deleteAccount - status: $status, serverResponse: $serverResp',
          name: 'ProfileRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }
}
