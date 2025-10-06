import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// GetIt is not used here; AuthBloc is injected by the caller
// router only defines routes; blocs are provided at app root via MultiBlocProvider
import '../../features/auth/app/bloc/auth_bloc.dart';
import '../../features/auth/app/bloc/auth_state.dart';

import '../../features/auth/app/pages/auth_page.dart';
import '../../features/catalog/app/pages/catalog_page.dart';
import '../../features/orders/app/pages/orders_page.dart';
import '../../features/payments/app/pages/payments_page.dart';
import '../../features/delivery/app/pages/delivery_page.dart';
import '../../features/notifications/app/pages/notifications_page.dart';
import '../../features/admin/app/pages/admin_page.dart';

// Use GoRouter's built-in GoRouterRefreshStream helper which converts a Stream
// into a ChangeNotifier that GoRouter can listen to.

class _StreamChangeNotifier extends ChangeNotifier {
  _StreamChangeNotifier(Stream<dynamic> stream) {
    _sub = stream.listen((event) {
      // ignore: avoid_print
      print('[router] stream event: $event');
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

GoRouter createRouter({required AuthBloc authBloc}) {
  // Convert the authBloc stream into a ChangeNotifier GoRouter can listen to
  final refresh = _StreamChangeNotifier(authBloc.stream);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = authBloc.state is Authenticated;
      final loc = state.uri.path;
      final loggingIn = loc == '/auth';
  // Debug: print redirect decision
  // ignore: avoid_print
  print('[router] redirect check - path: $loc, loggedIn: $loggedIn');
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
        builder: (context, state) => const AuthPage(),
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
      GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
    ],
  );
}
