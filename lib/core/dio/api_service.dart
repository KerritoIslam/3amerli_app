import 'package:dio/dio.dart';
import 'package:amerli_app/core/auth/auth_service.dart';
import 'package:amerli_app/core/dio/auth_interceptor.dart';
import 'dart:developer' as developer;

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio, String? baseUrl, AuthService? authService})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 10))) {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }

    // Add concise status logger for every response
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['startTime'] = DateTime.now();
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final started = response.requestOptions.extra['startTime'] as DateTime?;
          final elapsedMs = started != null ? DateTime.now().difference(started).inMilliseconds : null;
          final method = response.requestOptions.method;
          final path = response.requestOptions.path;
          final status = response.statusCode;
          developer.log(
            '[HTTP] $method $path -> $status${elapsedMs != null ? ' (${elapsedMs}ms)' : ''}',
            name: 'ApiService',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          final started = error.requestOptions.extra['startTime'] as DateTime?;
          final elapsedMs = started != null ? DateTime.now().difference(started).inMilliseconds : null;
          final method = error.requestOptions.method;
          final path = error.requestOptions.path;
          final status = error.response?.statusCode;
          developer.log(
            '[HTTP] $method $path -> ERROR${status != null ? ' $status' : ''}${elapsedMs != null ? ' (${elapsedMs}ms)' : ''}: ${error.message}',
            name: 'ApiService',
            error: error,
          );
          return handler.next(error);
        },
      ),
    );

    // Optional: verbose Dio logging (kept for deeper debugging)
    _dio.interceptors.add(LogInterceptor(request: true, requestBody: true, responseBody: false, responseHeader: false));

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
