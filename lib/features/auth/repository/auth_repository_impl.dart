import 'package:amerli_app/core/auth/auth_service.dart';
import 'package:amerli_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:amerli_app/features/auth/data/datasources/profile_local_datasource.dart';
import 'package:amerli_app/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource remote;
  final AuthService authService;
  final ProfileLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.authService, required this.local});

  Future<void> sendOtp(String phone) => remote.sendOtp(phone);

  /// Validate OTP and return whether user is registered.
  /// Backend response contains: accessToken, refreshToken, user, isRegistered
  Future<bool> validateOtp(String phone, String otp) async {
    final Map<String, dynamic> data = await remote.validateOtp(phone, otp);

    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    final userJson = data['user'] as Map<String, dynamic>?;
    final isRegistered = data['isRegistered'] as bool? ?? false;

    // Always save tokens (even if not registered) — backend requires them for registration
    if (access != null && refresh != null) {
      await authService.saveTokens(accessToken: access, refreshToken: refresh);
    }

    if (userJson != null) {
      await local.saveUserJson(userJson);
    }

    return isRegistered; // true -> existing user (go to Home), false -> new user (go to CompleteProfile)
  }

  /// Submit complete profile to the backend (PUT /authentication/register).
  /// Expects the backend to return the created user JSON which we cache.
  Future<void> register(Map<String, dynamic> profile) async {
    final resp = await remote.register(profile);
    // resp is the user JSON
    if (resp.isNotEmpty) {
      await local.saveUserJson(resp);
    }
  }

  Future<void> signOut() async {
    await authService.clear();
    await local.clear();
  }

  Future<UserModel?> readCachedUser() async {
    final j = await local.readUserJson();
    if (j == null) return null;
    print("User Model Read from local datasource: $j");
    return UserModel.fromJson(j);
  }
}
