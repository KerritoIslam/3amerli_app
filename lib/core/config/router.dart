import 'dart:async';
// import 'package:amerli_app/features/auth/app/pages/complete_profile_page.dart';
import 'package:amerli_app/features/auth/app/pages/complete_profile_page.dart';
import 'package:amerli_app/features/auth/app/pages/sign_up_page.dart';
import 'package:amerli_app/features/home/app/pages/home_page.dart';
import 'package:amerli_app/features/profile/app/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// GetIt is not used here; AuthBloc is injected by the caller
// router only defines routes; blocs are provided at app root via MultiBlocProvider
import '../../features/auth/app/bloc/auth_bloc.dart';
import '../../features/auth/app/bloc/auth_state.dart';
import '../storage/local_storage.dart';


import '../../features/catalog/app/pages/catalog_page.dart';
import '../../features/onboarding/app/pages/onboarding_flow.dart';
import '../../features/orders/app/pages/orders_page.dart';
import '../../features/payments/app/pages/payments_page.dart';
import '../../features/delivery/app/pages/delivery_page.dart';
import '../../features/notifications/app/pages/notifications_page.dart';
import '../../features/admin/app/pages/admin_page.dart';

// Use GoRouter's built-in GoRouterRefreshStream helper which converts a Stream
// into a ChangeNotifier that GoRouter can listen to.

class _StreamChangeNotifier extends ChangeNotifier {
  _StreamChangeNotifier(Stream<dynamic> stream) {
    _sub = stream.listen((_) {
      // intentionally left blank; refresh listener only
      notifyListeners();
    });
  }
  late final StreamSubscription _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({required AuthBloc authBloc, required LocalStorage localStorage}) {
  // Convert the authBloc stream into a ChangeNotifier GoRouter can listen to
  final refresh = _StreamChangeNotifier(authBloc.stream);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      // Keep routing decisions solely based on authentication state to avoid
      // redirect loops. The /auth route itself will render onboarding or
      // sign-up depending on whether onboarding was seen.
      final loggedIn = authBloc.state is Authenticated;
      final loc = state.uri.path;
      final loggingIn = loc == '/auth';

      if (!loggedIn && !loggingIn) return '/auth';
      if (loggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          final seen = localStorage.getBool('seen_onboarding') ?? false;
          if (!seen) return const OnboardingFlow();
          return const HomePage();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const CatalogPage(),
      ),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const CatalogPage(),
      ),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
      GoRoute(path: '/payments', builder: (context, state) => const PaymentsPage()),
      GoRoute(path: '/delivery', builder: (context, state) => const DeliveryPage()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsPage()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfilePage() ),
      GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
    ],
  );
}
