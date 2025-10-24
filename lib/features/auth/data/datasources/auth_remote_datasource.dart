import 'package:dio/dio.dart';
import 'package:amerli_app/core/dio/api_service.dart';

class AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSource({required this.apiService});

  /// Request sending OTP to phone number. Endpoint: POST /authentication/otp/send
  Future<void> sendOtp(String phone) async {
    try {
      print("DAta Sending OTP to $phone");

      final resp = await apiService.post('/authentication/otp/send', data: {'phoneNumber': phone});
      print("Response status code: ${resp.statusCode}");

      // Ensure backend responded with success; otherwise throw so callers can handle the error
      if (!((resp.statusCode == 200) || (resp.statusCode == 201))) {
        throw DioException(requestOptions: resp.requestOptions, response: resp);
      }
    } on DioException catch (e) {
      // log and rethrow so higher layers (cubit) can handle the error instead of optimistically moving to OTP state
      print("Error sending OTP: $e");
      rethrow;
    }
  }

  /// Validate OTP. Endpoint: POST /authentication/otp/validate
  /// Expects response with accessToken, refreshToken, user, isRegistered
  Future<Map<String, dynamic>> validateOtp(String phone, String otp) async {
    final resp = await apiService.post('/authentication/otp/validate', data: {'phoneNumber': phone, 'otp': otp});
    print("Register Data Response for validateOtp: ${resp.data}");
    if (((resp.statusCode == 201) || (resp.statusCode == 200)) && resp.data != null) {
      return Map<String, dynamic>.from(resp.data as Map);
    }
    throw DioError(requestOptions: resp.requestOptions, response: resp);
  }

  /// Register user (complete profile). Endpoint: PUT /authentication/register
  Future<Map<String, dynamic>> register(Map<String, dynamic> profile) async {
    // ApiService with AuthInterceptor will attach access token automatically;
    // but accept accessToken override for direct calls if needed.
    print("Register Data Sent: $profile");
    final resp = await apiService.client.put('/authentication/register', data: profile);
    print("Register status code: ${resp.statusCode}");
    print("Register Data Response: ${resp.data}");
    if (((resp.statusCode == 201) || (resp.statusCode == 200)) && resp.data != null) {
      return Map<String, dynamic>.from(resp.data as Map);
    }
    throw DioError(requestOptions: resp.requestOptions, response: resp);
  }

  /// Refresh tokens using a refresh token. Calls POST /authentication/refresh with
  /// Authorization: Bearer <refreshToken>. Uses a bare Dio instance to avoid
  /// interceptor loops.
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final baseUrl = apiService.client.options.baseUrl;
    final d = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));
    final resp = await d.post('/authentication/refresh', options: Options(headers: {'Authorization': 'Bearer $refreshToken'}));
    if (((resp.statusCode == 201) || (resp.statusCode == 200))&& resp.data != null) {
      return Map<String, dynamic>.from(resp.data as Map);
    }
    throw Exception('refresh_failed');
  }
}

