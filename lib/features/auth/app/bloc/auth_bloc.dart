import 'dart:async';
import 'package:flutter/foundation.dart'
    show kDebugMode, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../../../core/config/injection.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../utils/constants/app_language.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Logging methods
  void logInfo(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }

  void logWarning(String message) {
    if (kDebugMode) {
      print('[WARNING] $message');
    }
  }

  void logError(String message) {
    // Always log errors, even in release mode
    print('[ERROR] $message');
  }

  final AuthService authService;
  StreamSubscription<void>? _logoutSubscription;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    _logoutSubscription = authService.onLoggedOut.listen((_) {
      add(LogOutEvent());
    });

    on<LogInEvent>((event, emit) async {
      logInfo(
          '[AuthBloc] LogInEvent received for user: ${event.user.phoneNumber}');

      // Emit authenticated state first, then register FCM token
      emit(Authenticated(event.user));
      await _registerFcmToken();
    });
    on<LogOutEvent>((event, emit) {
      logInfo('[AuthBloc] LogOutEvent received');
      emit(Unauthenticated());
    });
    on<ToggleAuthEvent>((event, emit) {
      logInfo('[AuthBloc] ToggleAuthEvent received; current state: $state');
      if (state is Authenticated) {
        emit(Unauthenticated());
      } else {
        // Cannot toggle to Authenticated without a user payload; reset to initial instead
        emit(AuthInitial());
      }
    });
  }

  @override
  Future<void> close() {
    _logoutSubscription?.cancel();
    return super.close();
  }

  // Register FCM token with backend
  Future<void> _registerFcmToken() async {
    try {
      final notificationService = NotificationService();

      // Get FCM token
      final fcmToken = await notificationService.getFcmToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        logWarning('[AuthBloc] Failed to get FCM token');
        return;
      }

      logInfo('[AuthBloc] Registering FCM token: $fcmToken');

      // Register token with backend using enhanced retry mechanism
      await notificationService.registerTokenWithRetry(fcmToken);
      logInfo('[AuthBloc] FCM token registration initiated');
    } catch (e) {
      logError('[AuthBloc] Failed to register FCM token: $e');
      // Don't fail the login process if token registration fails
    }
  }

  // Handle FCM token refresh (call this from NotificationService when token changes)
  Future<void> handleTokenRefresh(String newToken) async {
    try {
      // Only register token if user is authenticated
      if (state is Authenticated) {
        logInfo('[AuthBloc] Handling FCM token refresh: $newToken');
        final notificationsRepository = sl<NotificationsRepository>();
        final os =
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
        await notificationsRepository.registerFcmToken(
            newToken, os, AppLanguage.current.name);
        logInfo('[AuthBloc] FCM token refresh registered successfully');
      }
    } catch (e) {
      logError('[AuthBloc] Failed to register refreshed FCM token: $e');
    }
  }
}
