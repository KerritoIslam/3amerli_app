import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/notifications/notification_service.dart';
import 'utils/logging/app_logger.dart';
import 'core/config/injection.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/catalog/app/bloc/catalog_bloc.dart';
import 'features/auth/app/bloc/auth_bloc.dart';
import 'features/auth/app/bloc/auth_event.dart';
import 'features/auth/app/bloc/profile_bloc.dart';
import 'features/auth/repository/auth_repository_impl.dart';
import 'core/auth/auth_service.dart';
import 'features/auth/domain/entities/supermarket.dart';
import 'features/notifications/app/bloc/notifications_bloc.dart';
import 'core/config/settings.dart';
import 'utils/constants/app_language.dart';
import 'utils/theme/app_theme.dart';
import 'core/config/router.dart';
import 'core/storage/local_storage.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

// routing will provide pages and blocs via DI where needed

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/cart/app/bloc/cart_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Lock orientation to portrait (vertical) only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  // Initialize Firebase if configured (guards against missing config in dev)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Safe to continue without Firebase in environments where it's not configured
  }
  await di.init();

  // Ensure selected app language is set from persisted settings before runApp
  final settings = di.sl<Settings>();
  // Map stored language code to AppLocale
  try {
    final code = settings.language;
    if (code == 'fr') {
      AppLanguage.current = AppLocale.fr;
    } else if (code == 'ar') {
      AppLanguage.current = AppLocale.ar;
    } else {
      AppLanguage.current = AppLocale.en;
    }
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Settings _settings;
  late final GoRouter _router;
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _settings = di.sl<Settings>();

    // Initialize router once in initState
    final authBloc = di.sl<AuthBloc>();
    final localStorage = di.sl<LocalStorage>();
    _router = createRouter(
        authBloc: authBloc,
        localStorage: localStorage,
        navigatorKey: MyApp.navigatorKey);

    // Apply language and listen for changes
    _applyLanguage(_settings.language);
    _settings.languageNotifier.addListener(_onLanguageChanged);

    // Setup notifications
    _setupNotifications();

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      final isOffline = result == ConnectivityResult.none;
      if (isOffline) {
        // Navigate to offline page if not already there
        final currentPath =
            _router.routerDelegate.currentConfiguration.uri.path;
        if (currentPath != '/offline') {
          _router.push('/offline');
        }
      } else {
        // If we are online and on offline page, go back
        final currentPath =
            _router.routerDelegate.currentConfiguration.uri.path;
        if (currentPath == '/offline') {
          if (_router.canPop()) {
            _router.pop();
          } else {
            _router.go('/home');
          }
        }
      }
    });
  }

  Future<void> _setupNotifications() async {
    try {
      final notificationService = NotificationService();
      await notificationService.init();
      notificationService.setOnNotificationTap(_handleNotificationTap);
    } catch (e, stackTrace) {
      AppLogger.error('Error setting up notifications', e, stackTrace);
    }
  }

  void _applyLanguage(String code) {
    if (code == 'fr') {
      AppLanguage.current = AppLocale.fr;
    } else if (code == 'ar') {
      AppLanguage.current = AppLocale.ar;
    } else {
      AppLanguage.current = AppLocale.en;
    }
  }

  void _onLanguageChanged() {
    // Update AppLanguage without triggering setState to avoid unnecessary rebuilds
    // The ValueListenableBuilder in build() will handle the UI update
    _applyLanguage(_settings.language);
  }

  @override
  void dispose() {
    // Remove language listener to prevent memory leaks
    _settings.languageNotifier.removeListener(_onLanguageChanged);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = di.sl<AuthBloc>();

    // Attempt auto-auth on startup: if tokens exist, try refresh and dispatch login
    Future.microtask(() async {
      try {
        final authRepo = di.sl<AuthRepositoryImpl>();
        AppLogger.debug('Checking tokens for auto-auth');
        final access = await di.sl<AuthService>().readAccessToken();
        final refresh = await di.sl<AuthService>().readRefreshToken();
        AppLogger.debug(
            'Access token: ${access != null ? 'present' : 'absent'}, Refresh token: ${refresh != null ? 'present' : 'absent'}');
        var ok = false;
        if (access != null) {
          // we have access token, try to read cached user
          final userModel = await authRepo.readCachedUser();
          if (userModel != null) {
            final userEntity = userModel.toEntity();
            final user = userEntity.role == 'SUPERMARKET'
                ? Supermarket.fromUser(userEntity)
                : userEntity;
            AppLogger.debug(
                'Found cached user, marking authenticated: ${user.phoneNumber}');
            authBloc.add(LogInEvent(user));
            ok = true;
          }
        }
        if (!ok && refresh != null) {
          AppLogger.debug('Trying to refresh tokens');
          final refreshed = await authRepo.refreshTokens();
          if (refreshed) {
            final userModel = await authRepo.readCachedUser();
            if (userModel != null) {
              final userEntity = userModel.toEntity();
              final user = userEntity.role == 'SUPERMARKET'
                  ? Supermarket.fromUser(userEntity)
                  : userEntity;
              AppLogger.debug(
                  'Refresh succeeded, logging in user: ${user.phoneNumber}');
              authBloc.add(LogInEvent(user));
              ok = true;
            }
          } else {
            AppLogger.debug('Token refresh failed');
          }
        }
        if (!ok) AppLogger.debug('No valid session found');
      } catch (e, stackTrace) {
        AppLogger.error('Auto-auth error', e, stackTrace);
      }
    });
    // Provide app-scoped blocs at the root so children can use context.read<T>()
    // Wrap everything in ValueListenableBuilder to force complete rebuild on language change
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, currentLocale, _) {
        // Use key on MultiBlocProvider to force complete widget tree rebuild
        return ScreenUtilInit(
          designSize: const Size(375, 812), // Standard iPhone X design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MultiBlocProvider(
              key: ValueKey('app_locale_${currentLocale.name}'),
              providers: [
                BlocProvider.value(value: di.sl<CatalogBloc>()),
                BlocProvider.value(value: di.sl<AuthBloc>()),
                BlocProvider.value(value: di.sl<NotificationsBloc>()),
                BlocProvider.value(value: di.sl<CartBloc>()), // Added CartBloc
                BlocProvider(create: (_) => di.sl<ProfileBloc>()),
              ],
              child: Directionality(
                textDirection: currentLocale == AppLocale.ar
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: MaterialApp.router(
                  key: ValueKey(
                      'material_app_${currentLocale.name}'), // Force complete rebuild on language change
                  debugShowCheckedModeBanner: false,
                  title: '3amerli',
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: ThemeMode.light,
                  routerConfig: _router,
                  locale: Locale(currentLocale.name),
                  // Ensure RTL support for Arabic - double wrap for maximum compatibility
                  builder: (context, child) {
                    return Directionality(
                      textDirection: currentLocale == AppLocale.ar
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Handle notification taps with deep linking
  void _handleNotificationTap(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      // Handle deep linking from notification data
      final data = message.data;

      // Example: Navigate to specific page based on notification type
      if (data.containsKey('type')) {
        final type = data['type'];
        switch (type) {
          case 'order':
            if (data.containsKey('orderId')) {
              _router.go('/admin/orders/${data['orderId']}');
            }
            break;
          case 'product':
            if (data.containsKey('productId')) {
              _router.go('/catalog');
              // You could add product detail navigation here
            }
            break;
          case 'promotion':
            _router.go('/catalog');
            break;
          default:
            _router.go('/home');
        }
      } else {
        // Default navigation if no specific type
        _router.go('/home');
      }
    } else {
      // Default navigation if no data
      _router.go('/home');
    }
  }
}
