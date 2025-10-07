import 'package:flutter/material.dart';
import 'core/config/injection.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/catalog/app/bloc/catalog_bloc.dart';
import 'features/auth/app/bloc/auth_bloc.dart';
import 'features/notifications/app/bloc/notifications_bloc.dart';
import 'core/config/settings.dart';
import 'utils/constants/app_language.dart';
import 'utils/theme/app_theme.dart';
import 'core/config/router.dart';
// routing will provide pages and blocs via DI where needed


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Settings _settings;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _settings = di.sl<Settings>();
    _themeMode = _settings.themeModeNotifier.value;

    // Apply language and listen for changes
    _applyLanguage(_settings.language);
    _settings.languageNotifier.addListener(() {
      _applyLanguage(_settings.language);
      setState(() {});
    });

    // Listen for theme changes
    _settings.themeModeNotifier.addListener(() {
      setState(() {
        _themeMode = _settings.themeModeNotifier.value;
      });
    });
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

  @override
  void dispose() {
    // Settings not disposed here as it's a singleton; we only remove listeners if needed.
    // Note: ValueNotifier listeners added above are lambdas; no direct handle to remove.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final authBloc = di.sl<AuthBloc>();
  final router = createRouter(authBloc: authBloc);
    // Provide app-scoped blocs at the root so children can use context.read<T>()
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<CatalogBloc>()),
        BlocProvider.value(value: di.sl<AuthBloc>()),
        BlocProvider.value(value: di.sl<NotificationsBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: '3amerli',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        routerConfig: router,
      ),
    );
  }
}
