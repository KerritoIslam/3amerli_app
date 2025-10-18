import 'dart:async';

import 'package:dio/dio.dart';
import 'package:amerli_app/core/auth/auth_service.dart';

/// Interceptor that attaches access token to requests and attempts to
/// refresh the token on 401 responses. It queues concurrent requests
/// while a refresh is in progress to avoid multiple simultaneous refreshes.
class AuthInterceptor extends Interceptor {
  final AuthService authService;
  final Dio dio;

  // track ongoing refresh
  Completer<void>? _refreshCompleter;

  AuthInterceptor({required this.authService, required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await authService.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      options.headers['Accept'] = 'application/json';
    } catch (_) {}
    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // Only attempt refresh for 401 from the API (and not when retrying)
    if (err.response?.statusCode == 401) {
      final req = err.requestOptions;

      // If a refresh is already running, wait for it
      if (_refreshCompleter != null) {
        try {
          await _refreshCompleter!.future;
        } catch (_) {
          // refresh failed
          return handler.next(err);
        }

        // After refresh, retry original request with new token
        try {
          final access = await authService.readAccessToken();
          if (access != null) {
            final opts = Options(method: req.method, headers: req.headers);
            req.headers['Authorization'] = 'Bearer $access';
            final response = await dio.request(req.path,
                data: req.data, queryParameters: req.queryParameters, options: opts);
            return handler.resolve(response);
          }
        } catch (e) {
          return handler.next(err);
        }
      } else {
        _refreshCompleter = Completer<void>();
        try {
          final success = await _refreshTokens();
          if (!success) {
            _refreshCompleter!.completeError(Exception('refresh_failed'));
            _refreshCompleter = null;
            return handler.next(err);
          }

          _refreshCompleter!.complete();
          _refreshCompleter = null;

          // retry the original request
          final access = await authService.readAccessToken();
          if (access != null) {
            final opts = Options(method: req.method, headers: req.headers);
            req.headers['Authorization'] = 'Bearer $access';
            final response = await dio.request(req.path,
                data: req.data, queryParameters: req.queryParameters, options: opts);
            return handler.resolve(response);
          }
        } catch (e) {
          _refreshCompleter?.completeError(e);
          _refreshCompleter = null;
          return handler.next(err);
        }
      }
    }

    return handler.next(err);
  }

  Future<bool> _refreshTokens() async {
    try {
      final refresh = await authService.readRefreshToken();
      if (refresh == null) return false;
      // Use a dedicated Dio instance without interceptors to avoid loops
      final d = Dio(BaseOptions(baseUrl: dio.options.baseUrl, connectTimeout: const Duration(seconds: 10)));
      // Backend expects refresh via POST /authentication/refresh with Authorization header
      final resp = await d.post('/authentication/refresh', options: Options(headers: {'Authorization': 'Bearer $refresh'}));

      if (resp.statusCode == 200 && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        final access = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        if (access != null && refreshToken != null) {
          await authService.saveTokens(accessToken: access, refreshToken: refreshToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
