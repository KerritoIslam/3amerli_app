import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio, String? baseUrl, String? jwtToken})
      : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 10))) {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }

    // Setup basic interceptors: add Authorization header when jwtToken provided
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (jwtToken != null && jwtToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $jwtToken';
      }
      // Example: add common headers
      options.headers['Accept'] = 'application/json';
      return handler.next(options);
    }, onError: (err, handler) {
      // Here you can handle global errors (refresh token etc.)
      return handler.next(err);
    }));
  }

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
