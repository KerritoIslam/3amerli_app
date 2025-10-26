import 'package:dio/dio.dart';
import 'package:amerli_app/core/dio/api_service.dart';

/// A simple API exception that higher layers can catch and display to the user.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  ApiException(this.message, {this.statusCode, this.isNetworkError = false});

  @override
  String toString() => 'ApiException(status: $statusCode, network: $isNetworkError): $message';
}

class AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) => status != null && status >= 200 && status < 300;

  /// Request sending OTP to phone number. Endpoint: POST /authentication/otp/send
  Future<void> sendOtp(String phone) async {
    try {
      print("DAta Sending OTP to $phone");

      final resp = await apiService.post('/authentication/otp/send', data: {'phoneNumber': phone});
      print("Response status code: ${resp.statusCode}");

      // Accept any 2xx response as success
      if (!_isSuccess(resp.statusCode)) {
        final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to send OTP';
        throw ApiException(msg, statusCode: resp.statusCode);
      }
    } on DioException catch (e) {
      // Network / transport level errors
      print("Dio error sending OTP: $e");
      final msg = e.message ?? 'Network error while sending OTP';
      throw ApiException(msg, statusCode: e.response?.statusCode, isNetworkError: true);
    } catch (e) {
      print("Unexpected error sending OTP: $e");
      throw ApiException('Unexpected error while sending OTP');
    }
  }

  /// Validate OTP. Endpoint: POST /authentication/otp/validate
  /// Expects response with accessToken, refreshToken, user, isRegistered
  Future<Map<String, dynamic>> validateOtp(String phone, String otp) async {
    try {
      final resp = await apiService.post('/authentication/otp/validate', data: {'phoneNumber': phone, 'otp': otp});
      print("Register Data Response for validateOtp: ${resp.data}");
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return Map<String, dynamic>.from(resp.data as Map);
      }

      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Invalid OTP or server error';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      print("Dio error validateOtp: $e");
      final msg = e.message ?? 'Network error while validating OTP';
      throw ApiException(msg, statusCode: e.response?.statusCode, isNetworkError: true);
    } catch (e) {
      print("Unexpected error validateOtp: $e");
      throw ApiException('Unexpected error while validating OTP');
    }
  }

  /// Register user (complete profile). Endpoint: PUT /authentication/register
  Future<Map<String, dynamic>> register(Map<String, dynamic> profile) async {
    try {
      print("Register Data Sent: $profile");
      final resp = await apiService.client.put('/authentication/register', data: profile);
      print("Register status code: ${resp.statusCode}");
      print("Register Data Response: ${resp.data}");
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return Map<String, dynamic>.from(resp.data as Map);
      }

      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Registration failed';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      print("Dio error register: $e");
      final msg = e.message ?? 'Network error while registering';
      throw ApiException(msg, statusCode: e.response?.statusCode, isNetworkError: true);
    } catch (e) {
      print("Unexpected error register: $e");
      throw ApiException('Unexpected error while registering');
    }
  }

  /// Refresh tokens using a refresh token. Calls POST /authentication/refresh with
  /// Authorization: Bearer <refreshToken>. Uses a bare Dio instance to avoid
  /// interceptor loops.
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    try {
      final baseUrl = apiService.client.options.baseUrl;
      final d = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));
      final resp = await d.post('/authentication/refresh', options: Options(headers: {'Authorization': 'Bearer $refreshToken'}));
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return Map<String, dynamic>.from(resp.data as Map);
      }

      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to refresh token';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      print("Dio error refresh: $e");
      final msg = e.message ?? 'Network error while refreshing token';
      throw ApiException(msg, statusCode: e.response?.statusCode, isNetworkError: true);
    } catch (e) {
      print("Unexpected error refresh: $e");
      throw ApiException('Unexpected error while refreshing token');
    }
  }
}

