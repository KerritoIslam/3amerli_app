import 'package:dio/dio.dart';
import 'package:amerli_app/core/auth/auth_service.dart';
import 'package:amerli_app/core/dio/auth_interceptor.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio, String? baseUrl, AuthService? authService})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 10))) {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }

    // Add logging interceptor to help debug network issues (only basic logging)
    _dio.interceptors.add(LogInterceptor(request: true, requestBody: true, responseBody: true, responseHeader: false));

    // Register auth interceptor if provided
    if (authService != null) {
      _dio.interceptors.add(AuthInterceptor(authService: authService, dio: _dio));
    } else {
      // default headers
      _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      }));
    }
  }

  Dio get client => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.delete(path, queryParameters: queryParameters);
  }
}
