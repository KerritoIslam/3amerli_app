import 'package:dio/dio.dart';
import 'package:amerli_app/core/auth/auth_service.dart';
import 'package:amerli_app/core/dio/auth_interceptor.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio, String? baseUrl, AuthService? authService})
      : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          validateStatus: (status) => status != null && status < 500, // Don't throw on 4xx errors
        )) {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }
    // Ensure validateStatus is set even if dio instance is provided
    _dio.options.validateStatus = (status) => status != null && status < 500;

    // Add concise and colorized status logger for every request/response/error
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['startTime'] = DateTime.now();
          try {
            const yellow = '\x1B[33m';
            const reset = '\x1B[0m';
            final method = options.method;
            final path = options.path;
            final qp = options.queryParameters.isNotEmpty ? options.queryParameters : null;
            final data = options.data != null ? options.data : null;
            // ignore: avoid_print
            print('$yellow[HTTP REQUEST] $method $path | query:$qp | data:$data$reset');
          } catch (_) {}
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final started = response.requestOptions.extra['startTime'] as DateTime?;
          final elapsedMs = started != null ? DateTime.now().difference(started).inMilliseconds : null;
          final method = response.requestOptions.method;
          final path = response.requestOptions.path;
          final status = response.statusCode;
          const green = '\x1B[32m';
          const reset = '\x1B[0m';
          final bodyPreview = response.data is Map || response.data is List ? response.data : response.data?.toString();
          // ignore: avoid_print
          print('$green[HTTP RESPONSE] $method $path -> $status${elapsedMs != null ? ' (${elapsedMs}ms)' : ''} | body: $bodyPreview$reset');
          return handler.next(response);
        },
        onError: (error, handler) {
          final started = error.requestOptions.extra['startTime'] as DateTime?;
          final elapsedMs = started != null ? DateTime.now().difference(started).inMilliseconds : null;
          final method = error.requestOptions.method;
          final path = error.requestOptions.path;
          final status = error.response?.statusCode;
          final serverBody = error.response?.data;
          const yellow = '\x1B[33m';
          const green = '\x1B[32m';
          const red = '\x1B[31m';
          const reset = '\x1B[0m';

          // Request info (yellow)
          try {
            final qp = error.requestOptions.queryParameters.isNotEmpty ? error.requestOptions.queryParameters : null;
            final reqData = error.requestOptions.data != null ? error.requestOptions.data : null;
            // ignore: avoid_print
            print('$yellow[HTTP ERROR - REQUEST] $method $path | query:$qp | data:$reqData$reset');
          } catch (_) {}

          // Response info (green)
          try {
            // ignore: avoid_print
            print('$green[HTTP ERROR - RESPONSE] status:${status ?? 'unknown'} | body: ${serverBody ?? 'null'}${elapsedMs != null ? ' (${elapsedMs}ms)' : ''}$reset');
          } catch (_) {}

          // Exception message (red)
          try {
            // ignore: avoid_print
            print('$red[HTTP ERROR - EXCEPTION] ${error.message}$reset');
          } catch (_) {}

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

void main() {
  const yellow = '\x1B[33m';
  const green = '\x1B[32m';
  const red = '\x1B[31m';
  const reset = '\x1B[0m';

  print('$yellow This should be yellow $reset');
  print('$green This should be green $reset');
  print('$red This should be red $reset');
}
