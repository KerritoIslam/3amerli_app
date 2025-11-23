import 'dart:async';

import 'package:dio/dio.dart';
import 'dart:developer' show log;
import 'package:amerli_app/core/auth/auth_service.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

/// Interceptor that attaches access token to requests and attempts to
/// refresh the token on 401 responses. It queues concurrent requests
/// while a refresh is in progress to avoid multiple simultaneous refreshes.
class AuthInterceptor extends Interceptor {
  final AuthService authService;
  final Dio dio;

  // track ongoing refresh
  Completer<void>? _refreshCompleter;

  AuthInterceptor({required this.authService, required this.dio});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await authService.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      // If the request is the registration endpoint, attach the week token
      // returned after OTP validation. This header is intentionally separate
      // from the regular Authorization header and will only be sent to the
      // register endpoint.
      final path = options.path;
      // Match exact register path (server uses /authentication/register)
      if (path.endsWith('/authentication/register') ||
          path == '/authentication/register') {
        final week = await authService.readWeekToken();
        if (week != null && week.isNotEmpty) {
          log("Register Data Response Register week token: $week",
              name: 'AuthInterceptor');
          options.headers['Authorization'] = 'Bearer $week';
        }
      }
      options.headers['Accept'] = 'application/json';
    } catch (_) {}
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Handle 401 Unauthorized - Token Refresh
    if (response.statusCode == 401) {
      log('AuthInterceptor: Received 401 in onResponse, attempting token refresh',
          name: 'AuthInterceptor');
      final req = response.requestOptions;

      // If a refresh is already running, wait for it then retry
      if (_refreshCompleter != null) {
        try {
          await _refreshCompleter!.future;
        } catch (_) {
          // refresh failed - clear local auth state and forward original 401
          try {
            await authService.clear();
            log('AuthInterceptor: cleared tokens after concurrent refresh failure',
                name: 'AuthInterceptor');
          } catch (_) {}
          return handler.next(response);
        }

        // After refresh, retry original request with new token
        try {
          final access = await authService.readAccessToken();
          if (access != null) {
            final opts = Options(method: req.method, headers: req.headers);
            req.headers['Authorization'] = 'Bearer $access';
            final newResponse = await dio.request(req.path,
                data: req.data,
                queryParameters: req.queryParameters,
                options: opts);
            return handler.next(newResponse);
          }
        } catch (e) {
          return handler.next(response);
        }
      }

      // Otherwise start a refresh flow
      _refreshCompleter = Completer<void>();
      try {
        final success = await _refreshTokens();
        if (!success) {
          _refreshCompleter!.completeError(Exception('refresh_failed'));
          _refreshCompleter = null;
          // on refresh failure, clear stored tokens (force logout)
          try {
            await authService.clear();
            log('AuthInterceptor: cleared tokens after refresh failure',
                name: 'AuthInterceptor');
          } catch (_) {}
          return handler.next(response);
        }

        _refreshCompleter!.complete();
        _refreshCompleter = null;

        // retry the original request with the latest token
        final access = await authService.readAccessToken();
        if (access != null) {
          final opts = Options(method: req.method, headers: req.headers);
          req.headers['Authorization'] = 'Bearer $access';
          final newResponse = await dio.request(req.path,
              data: req.data,
              queryParameters: req.queryParameters,
              options: opts);
          return handler.next(newResponse);
        }
      } catch (e) {
        _refreshCompleter?.completeError(e);
        _refreshCompleter = null;
        // clear tokens on unexpected refresh error
        try {
          await authService.clear();
          log('AuthInterceptor: cleared tokens after refresh exception',
              name: 'AuthInterceptor');
        } catch (_) {}
        return handler.next(response);
      }
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle error ranges instead of strict values.
    // Client errors: 400-499, Server errors: 500-599
    // Note: 401 is handled in onResponse because validateStatus allows it.
    // However, if validateStatus changes, we keep this logic here as fallback.
    final status = err.response?.statusCode;

    // Only attempt refresh when we receive a 401 Unauthorized from the API.
    if (status == 401) {
      log('AuthInterceptor: Received 401 in onError, attempting token refresh',
          name: 'AuthInterceptor');
      final req = err.requestOptions;

      // If a refresh is already running, wait for it then retry
      if (_refreshCompleter != null) {
        try {
          await _refreshCompleter!.future;
        } catch (_) {
          // refresh failed - clear local auth state and forward error
          try {
            await authService.clear();
            log('AuthInterceptor: cleared tokens after concurrent refresh failure',
                name: 'AuthInterceptor');
          } catch (_) {}
          return handler.next(err);
        }

        // After refresh, retry original request with new token
        try {
          final access = await authService.readAccessToken();
          if (access != null) {
            final opts = Options(method: req.method, headers: req.headers);
            req.headers['Authorization'] = 'Bearer $access';
            final response = await dio.request(req.path,
                data: req.data,
                queryParameters: req.queryParameters,
                options: opts);
            return handler.resolve(response);
          }
        } catch (e) {
          return handler.next(err);
        }
      }

      // Otherwise start a refresh flow
      _refreshCompleter = Completer<void>();
      try {
        final success = await _refreshTokens();
        if (!success) {
          _refreshCompleter!.completeError(Exception('refresh_failed'));
          _refreshCompleter = null;
          // on refresh failure, clear stored tokens (force logout)
          try {
            await authService.clear();
            log('AuthInterceptor: cleared tokens after refresh failure',
                name: 'AuthInterceptor');
          } catch (_) {}
          return handler.next(err);
        }

        _refreshCompleter!.complete();
        _refreshCompleter = null;

        // retry the original request with the latest token
        final access = await authService.readAccessToken();
        if (access != null) {
          final opts = Options(method: req.method, headers: req.headers);
          req.headers['Authorization'] = 'Bearer $access';
          final response = await dio.request(req.path,
              data: req.data,
              queryParameters: req.queryParameters,
              options: opts);
          return handler.resolve(response);
        }
      } catch (e) {
        _refreshCompleter?.completeError(e);
        _refreshCompleter = null;
        // clear tokens on unexpected refresh error
        try {
          await authService.clear();
          log('AuthInterceptor: cleared tokens after refresh exception',
              name: 'AuthInterceptor');
        } catch (_) {}
        return handler.next(err);
      }
    }

    // For other statuses (including server errors 5xx), just forward the error.
    return handler.next(err);
  }

  Future<bool> _refreshTokens() async {
    try {
      log('AuthInterceptor: Starting token refresh', name: 'AuthInterceptor');
      final refresh = await authService.readRefreshToken();
      if (refresh == null) {
        log('AuthInterceptor: No refresh token found', name: 'AuthInterceptor');
        return false;
      }
      log('AuthInterceptor: Refresh token found, calling /authentication/refresh',
          name: 'AuthInterceptor');
      // Use a dedicated Dio instance without interceptors to avoid loops
      final d = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        validateStatus: (status) =>
            true, // Accept all status codes to handle errors manually
      ));
      // Backend expects refresh via POST /authentication/refresh with Authorization header
      final resp = await d.post('/authentication/refresh',
          queryParameters: {'lang': AppLanguage.current.name},
          options: Options(headers: {'Authorization': 'Bearer $refresh'}));

      log('AuthInterceptor: Refresh response status: ${resp.statusCode}',
          name: 'AuthInterceptor');
      // consider any 2xx as success
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        final access = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        if (access != null && refreshToken != null) {
          await authService.saveTokens(
              accessToken: access, refreshToken: refreshToken);
          log('AuthInterceptor: Tokens refreshed successfully',
              name: 'AuthInterceptor');
          return true;
        }
      }
      log('AuthInterceptor: Refresh failed - invalid response',
          name: 'AuthInterceptor');
      return false;
    } catch (e) {
      log('AuthInterceptor: Refresh failed with exception: $e',
          name: 'AuthInterceptor');
      return false;
    }
  }
}
