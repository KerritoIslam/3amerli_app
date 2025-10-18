import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple auth service to persist access and refresh tokens and provide
/// helpers for reading/updating them. Uses flutter_secure_storage.
class AuthService {
  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _weekKey = 'auth_week_token';

  final FlutterSecureStorage _storage;

  AuthService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  /// Save a short-lived week token returned after OTP validation.
  /// This token is intended to be used only for the registration endpoint.
  Future<void> saveWeekToken(String weekToken) => _storage.write(key: _weekKey, value: weekToken);

  /// Read the week token stored after OTP validation.
  Future<String?> readWeekToken() => _storage.read(key: _weekKey);

  /// Delete the stored week token.
  Future<void> deleteWeekToken() => _storage.delete(key: _weekKey);

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _weekKey),
    ]);
  }
}
