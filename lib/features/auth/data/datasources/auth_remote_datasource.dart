import 'package:dio/dio.dart';
import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/core/network/error_message_extractor.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'dart:developer' as developer;

class AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  /// Request sending OTP to phone number. Endpoint: POST /authentication/otp/send
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      // debug: sending OTP (keep minimal logging)
      // ignore: avoid_print
      print("DAta Sending OTP to $phone");

      final resp = await apiService
          .post('/authentication/otp/send', data: {'phoneNumber': phone});
      print("Response status code: ${resp.statusCode}");

      // Accept any 2xx response as success
      if (_isSuccess(resp.statusCode)) {
        if (resp.data is Map<String, dynamic>) {
          return resp.data as Map<String, dynamic>;
        }
        return <String, dynamic>{};
      }

      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error sendOtp - status: $status, serverResponse: $serverResp',
          name: 'AuthRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    } catch (e, st) {
      // If it's already an ApiException, re-throw as-is
      if (e is ApiException) {
        rethrow;
      }
      developer.log('Unexpected error sending OTP: $e',
          name: 'AuthRemoteDataSource',
          error: e,
          stackTrace: st as StackTrace?);
      throw ApiException('Unexpected error while sending OTP');
    }
  }

  /// Validate OTP. Endpoint: POST /authentication/otp/validate
  /// Expects response with accessToken, refreshToken, user, isRegistered
  Future<Map<String, dynamic>> validateOtp(String phone, String otp) async {
    try {
      final resp = await apiService.post('/authentication/otp/validate',
          data: {'phoneNumber': phone, 'otp': otp});
      print("Register Data Response for validateOtp: ${resp.data}");
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
          'Dio error validateOtp - status: $status, serverResponse: $serverResp',
          name: 'AuthRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    } catch (e, st) {
      // If it's already an ApiException (from line 68), re-throw as-is
      if (e is ApiException) {
        rethrow;
      }
      developer.log('Unexpected error validateOtp: $e',
          name: 'AuthRemoteDataSource',
          error: e,
          stackTrace: st as StackTrace?);
      throw ApiException('Unexpected error while validating OTP');
    }
  }

  /// Register user (complete profile). Endpoint: PUT /authentication/register
  Future<Map<String, dynamic>> register(Map<String, dynamic> profile) async {
    try {
      print("Register Data Sent: $profile");
      final resp = await apiService.client
          .put('/authentication/register', data: profile);
      print("Register status code: ${resp.statusCode}");
      print("Register Data Response: ${resp.data}");
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
          'Dio error register - status: $status, serverResponse: $serverResp',
          name: 'AuthRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    } catch (e, st) {
      // If it's already an ApiException, re-throw as-is
      if (e is ApiException) {
        rethrow;
      }
      developer.log('Unexpected error register: $e',
          name: 'AuthRemoteDataSource',
          error: e,
          stackTrace: st as StackTrace?);
      throw ApiException('Unexpected error while registering');
    }
  }

  /// Refresh tokens using a refresh token. Calls POST /authentication/refresh with
  /// Authorization: Bearer <refreshToken>. Uses a bare Dio instance to avoid
  /// interceptor loops.
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    try {
      final baseUrl = apiService.client.options.baseUrl;
      final d = Dio(BaseOptions(
          baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));
      final resp = await d.post('/authentication/refresh',
          queryParameters: {'lang': AppLanguage.current.name},
          options: Options(headers: {'Authorization': 'Bearer $refreshToken'}));
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
          'Dio error refresh - status: $status, serverResponse: $serverResp',
          name: 'AuthRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    } catch (e, st) {
      // If it's already an ApiException, re-throw as-is
      if (e is ApiException) {
        rethrow;
      }
      developer.log('Unexpected error refresh: $e',
          name: 'AuthRemoteDataSource',
          error: e,
          stackTrace: st as StackTrace?);
      throw ApiException('Unexpected error while refreshing token');
    }
  }

  /// Logout current user in backend with FCM token. Endpoint: POST /authentication/logout
  Future<void> logout(String fcmToken) async {
    try {
      final resp = await apiService.post('/authentication/logout', data: {
        'fcmToken': fcmToken,
      });
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error logout - status: $status, serverResponse: $serverResp',
          name: 'AuthRemoteDataSource',
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
