import 'package:amerli_app/core/auth/auth_service.dart';
import 'package:amerli_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:amerli_app/features/auth/data/datasources/profile_local_datasource.dart';
import 'package:amerli_app/features/auth/data/models/user_model.dart';
import 'package:amerli_app/core/notifications/notification_service.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource remote;
  final AuthService authService;
  final ProfileLocalDataSource local;

  AuthRepositoryImpl(
      {required this.remote, required this.authService, required this.local});

  Future<void> sendOtp(String phone) => remote.sendOtp(phone);

  Future<bool> validateOtp(String phone, String otp) async {
    final Map<String, dynamic> data = await remote.validateOtp(phone, otp);

    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    final userJson = data['user'] as Map<String, dynamic>?;
    final isRegistered = data['isRegistered'] as bool? ?? false;

    // Backend may return a temporary 'week' token on OTP validation which
    // should be used only for registration. If the user is not registered,
    // treat the returned access token as a week token and store it separately.
    if (!isRegistered) {
      if (access != null) {
        await authService.saveWeekToken(access);
      }
      // do not persist refresh token for unregistered users
    } else {
      // existing user: persist real access/refresh tokens
      if (access != null && refresh != null) {
        await authService.saveTokens(
            accessToken: access, refreshToken: refresh);
      }
    }

    if (userJson != null) {
      await local.saveUserJson(userJson);
    }

    return isRegistered; // true -> existing user (go to Home), false -> new user (go to CompleteProfile)
  }

  /// Register user and return the server user JSON on success.
  /// Throws whatever `remote.register` throws on failure.
  Future<Map<String, dynamic>> register(Map<String, dynamic> profile) async {
    final resp = await remote.register(profile);
    print("Register Response: $resp");
    // resp contains {accessToken, refreshToken, user, isRegistered}
    // Extract only the user object to save
    final userJson = resp['user'] as Map<String, dynamic>?;
    if (userJson != null && userJson.isNotEmpty) {
      await local.saveUserJson(userJson);
    }
    return resp;
  }

  Future<void> signOut() async {
    try {
      // Attempt backend logout with current FCM token if available
      final fcmToken = await NotificationService().getFcmToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await remote.logout(fcmToken);
      }
    } catch (_) {
      // Ignore logout failures locally; proceed to clear auth state
    }
    await authService.clear();
    await local.clear();
  }

  /// Try to refresh tokens using stored refresh token. Returns true on success.
  Future<bool> refreshTokens() async {
    try {
      final refresh = await authService.readRefreshToken();
      if (refresh == null) return false;
      final data = await remote.refresh(refresh);
      final access = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final userJson = data['user'] as Map<String, dynamic>?;
      if (access != null && refreshToken != null) {
        await authService.saveTokens(
            accessToken: access, refreshToken: refreshToken);
      }
      if (userJson != null) {
        await local.saveUserJson(userJson);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> readCachedUser() async {
    final j = await local.readUserJson();
    if (j == null) return null;
    print("User Model Read from local datasource: $j");
    return UserModel.fromJson(j);
  }
}
