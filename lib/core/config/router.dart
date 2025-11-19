import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../../utils/constants/app_language.dart';
// import 'package:amerli_app/features/auth/app/pages/complete_profile_page.dart';
import 'package:amerli_app/features/auth/app/pages/sign_up_page.dart';
import 'package:amerli_app/features/home/app/pages/home_page.dart';
import 'package:amerli_app/features/auth/app/pages/complete_profile_page.dart';
import 'package:amerli_app/features/profile/app/pages/profile_page.dart';
import 'package:amerli_app/features/success/app/pages/success_page.dart';
import 'package:amerli_app/features/failure/app/pages/failure_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// GetIt is not used here; AuthBloc is injected by the caller
// router only defines routes; blocs are provided at app root via MultiBlocProvider
import '../../features/auth/app/bloc/auth_bloc.dart';
import '../../features/auth/app/bloc/auth_state.dart';
import '../storage/local_storage.dart';

import '../../features/catalog/app/pages/catalog_page.dart';
import '../../features/onboarding/app/pages/onboarding_flow.dart';
import '../../features/delivery/app/pages/delivery_page.dart';
import '../../features/notifications/app/pages/notifications_page.dart';
import '../../features/admin/app/pages/admin_page.dart';
import '../../features/admin/products/app/pages/add_product_page.dart';
import '../../features/admin/products/app/bloc/admin_products_bloc.dart';
import '../../features/admin/categories/app/pages/admin_categories_page.dart';
import '../../features/admin/categories/app/pages/add_category_page.dart';
import '../../features/admin/categories/app/bloc/admin_categories_bloc.dart';
import '../../features/admin/orders/app/pages/order_detail_page.dart';
import '../../features/admin/orders/app/bloc/admin_orders_bloc.dart';
import '../../features/admin/users/app/pages/user_detail_page.dart';
import '../../features/admin/users/app/bloc/admin_users_bloc.dart';
import 'package:amerli_app/features/favorits/app/pages/favorits_page.dart';
import '../../features/catalog/app/pages/filters_page.dart';
import '../../features/catalog/app/pages/categories_page.dart';
import '../../features/catalog/app/pages/brands_page.dart';
import '../../features/admin/users/app/pages/admin_users_filters_categories.dart';
import '../../features/admin/users/app/pages/admin_users_filters_brands.dart';
import '../../features/catalog/app/bloc/categories_bloc.dart';
import '../../features/catalog/app/bloc/brands_bloc.dart';
import '../../features/catalog/app/bloc/catalog_bloc.dart';
import '../config/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/favorits/app/bloc/favorits_bloc.dart'
    as fav_feature;
import 'package:amerli_app/features/auth/sign_up/sign_up_cubit.dart';

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

// Combined notifier that listens to multiple ChangeNotifiers
class _CombinedChangeNotifier extends ChangeNotifier {
  final List<ChangeNotifier> _notifiers;
  final List<VoidCallback> _listeners = [];

  _CombinedChangeNotifier(this._notifiers) {
    for (final notifier in _notifiers) {
      void listener() => notifyListeners();
      notifier.addListener(listener);
      _listeners.add(listener);
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _notifiers.length; i++) {
      _notifiers[i].removeListener(_listeners[i]);
    }
    super.dispose();
  }
}

GoRouter createRouter(
    {required AuthBloc authBloc, required LocalStorage localStorage}) {
  // Convert the authBloc stream into a ChangeNotifier GoRouter can listen to
  final authRefresh = _StreamChangeNotifier(authBloc.stream);
  
  // Also listen to language changes to refresh routes when language changes
  // Create a combined notifier that listens to both auth and language changes
  final combinedRefresh = _CombinedChangeNotifier([
    authRefresh,
    AppLanguage.localeNotifier, // Listen to language changes
  ]);

  return GoRouter(
    // Start the app at the authentication entrypoint. The previous root
    // (`/`) returned a `SizedBox.shrink()` which produced a black/empty
    // screen until a redirect happened; using '/auth' makes the initial
    // visible page explicit and avoids a blank frame on startup.
    initialLocation: '/auth',
    refreshListenable: combinedRefresh,
    redirect: (context, state) {
      final loc = state.uri.path;
      final fullUri = state.uri.toString();
      final scheme = state.uri.scheme;
      final host = state.uri.host;

      // Debug: Log all navigation attempts
      // ignore: avoid_print

      // Check if this is a deep link with custom scheme (amerli://success or amerli://failure)
      if (scheme == 'amerli' && (host == 'success' || host == 'failure')) {
        if (kDebugMode) {
          print('🔗 Deep link detected, allowing navigation');
        }
        return null; // Allow the deep link to proceed
      }

      // Define which paths are non-protected (allowed when unauthenticated).
      final nonProtected = <String>{
        '/',
        '/auth',
        '/complete-profile',
        '/payment/success', // Allow deep link access
        '/payment/failure', // Allow deep link access
        '/success', // Allow custom scheme deep link (amerli://success)
        '/failure', // Allow custom scheme deep link (amerli://failure)
      };
      final loggedIn = authBloc.state is Authenticated;

      final isNonProtected = nonProtected.contains(loc) ||
          nonProtected.any((p) => loc.startsWith(p));

      if (kDebugMode) {
        print('🔗 loggedIn=$loggedIn, isNonProtected=$isNonProtected');
      }

      // If not logged in and trying to access a protected route, send to /auth
      if (!loggedIn && !isNonProtected) {
        if (kDebugMode) {
          print('🔗 Redirecting to /auth (not logged in)');
        }
        return '/auth';
      }

      // If logged in, check for admin role and redirect accordingly
      if (loggedIn) {
        final authState = authBloc.state;
        if (authState is Authenticated) {
          final userRole = authState.user.role;

          // If admin tries to access regular home, redirect to admin
          if (userRole == 'ADMIN' && loc == '/home') {
            if (kDebugMode) {
              print(
                  '🔗 Admin user trying to access /home, redirecting to /admin');
            }
            return '/admin';
          }

          // If regular user tries to access admin, redirect to home
          if (userRole != 'ADMIN' && loc == '/admin') {
            if (kDebugMode) {
              print(
                  '🔗 Non-admin user trying to access /admin, redirecting to /home');
            }
            return '/home';
          }
        }
      }

      // If logged in but at auth path, send to home or admin based on role
      if (loggedIn && (loc == '/auth' || (loc == '/' && scheme != 'amerli'))) {
        if (kDebugMode) {
          print('🔗 Redirecting to home/admin (logged in at auth)');
        }

        // Check if user is admin
        final authState = authBloc.state;
        if (authState is Authenticated) {
          final userRole = authState.user.role;
          if (userRole == 'ADMIN') {
            if (kDebugMode) {
              print('🔗 User is ADMIN, redirecting to /admin');
            }
            return '/admin';
          }
        }

        return '/home';
      }

      // ignore: avoid_print
      print('🔗 No redirect needed');
      return null;
    },
    routes: [
      // Special handler for root path "/" - handles custom scheme deep links
      GoRoute(
        path: '/',
        builder: (context, state) {
          // Check if this is a deep link with custom scheme
          final uri = state.uri;
          // ignore: avoid_print
          print(
              '🏠 Root path accessed: scheme=${uri.scheme}, host=${uri.host}, fullUri=$uri');

          if (uri.scheme == 'amerli' && uri.host == 'success') {
            final params = uri.queryParameters;
            // ignore: avoid_print
            print('✅ Deep link success detected, building SuccessPage');
            return SuccessPage(
              orderId: params['orderId'],
              date: params['date'],
              paymentMethod: params['paymentMethod'] ?? params['payementWay'],
              amount: params['amount'] ?? params['total'],
              invoiceUrl: params['invoiceUrl'],
            );
          } else if (uri.scheme == 'amerli' && uri.host == 'failure') {
            final params = uri.queryParameters;
            // ignore: avoid_print
            print('❌ Deep link failure detected, building FailurePage');
            return FailurePage(
              orderId: params['orderId'],
              date: params['date'],
              paymentMethod: params['paymentMethod'] ?? params['payementWay'],
              amount: params['amount'] ?? params['total'],
              failureReason:
                  params['reason'] ?? params['error'] ?? 'Erreur inconnue',
            );
          }

          // Default: return empty container, will be redirected by redirect logic
          return const SizedBox.shrink();
        },
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          final seen = localStorage.getBool('seen_onboarding') ?? false;
          if (!seen) return const OnboardingFlow();
          return const SignUpPage();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is SignUpCubit) {
            return BlocProvider.value(
                value: extra, child: const CompleteProfilePage());
          }
          return const CompleteProfilePage();
        },
      ),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const CatalogPage(),
      ),
      // Filters and related pages
      GoRoute(
        path: '/filters',
        builder: (context, state) {
          return BlocProvider.value(
            value: sl<CatalogBloc>(),
            child: const FiltersPage(),
          );
        },
      ),
      GoRoute(
        path: '/filters/categories',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<CategoriesBloc>(
                create: (_) => sl<CategoriesBloc>(),
              ),
              BlocProvider.value(
                value: sl<CatalogBloc>(),
              ),
            ],
            child: const CategoriesPage(),
          );
        },
      ),
      GoRoute(
        path: '/filters/brands',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<BrandsBloc>(
                create: (_) => sl<BrandsBloc>(),
              ),
              BlocProvider.value(
                value: sl<CatalogBloc>(),
              ),
            ],
            child: const BrandsPage(),
          );
        },
      ),
      GoRoute(
        path: '/favorits',
        builder: (context, state) {
          // Provide FavoritsBloc locally for this route
          return BlocProvider<fav_feature.FavoritsBloc>(
            create: (_) => sl<fav_feature.FavoritsBloc>(),
            child: const FavoritsPage(),
          );
        },
      ),

      GoRoute(
          path: '/delivery', builder: (context, state) => const DeliveryPage()),
      GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsPage()),
      GoRoute(
          path: '/profile', builder: (context, state) => const ProfilePage()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
      GoRoute(
        path: '/admin/products/add',
        builder: (context, state) {
          return BlocProvider.value(
            value: sl<AdminProductsBloc>(),
            child: const AddProductPage(),
          );
        },
      ),
      GoRoute(
        path: '/admin/products/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return BlocProvider.value(
            value: sl<AdminProductsBloc>(),
            child: AddProductPage(productId: id),
          );
        },
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<AdminCategoriesBloc>(),
            child: const AdminCategoriesPage(),
          );
        },
      ),
      GoRoute(
        path: '/admin/categories/add',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<AdminCategoriesBloc>(),
            child: const AddCategoryPage(),
          );
        },
      ),
      GoRoute(
        path: '/admin/categories/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return BlocProvider(
            create: (_) => sl<AdminCategoriesBloc>(),
            child: AddCategoryPage(categoryId: id),
          );
        },
      ),
      GoRoute(
        path: '/admin/orders/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<AdminOrdersBloc>(),
            child: OrderDetailPage(orderId: id),
          );
        },
      ),
      GoRoute(
        path: '/admin/users/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<AdminUsersBloc>(),
            child: UserDetailPage(userId: id),
          );
        },
      ),
      GoRoute(
        path: '/admin/users/filters/categories',
        builder: (context, state) => const AdminUsersFiltersCategoriesPage(),
      ),
      GoRoute(
        path: '/admin/users/filters/brands',
        builder: (context, state) => const AdminUsersFiltersBrandsPage(),
      ),

      // Deep link routes for payment success/failure (HTTPS format)
      GoRoute(
        path: '/payment/success',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          return SuccessPage(
            orderId: params['orderId'],
            date: params['date'],
            paymentMethod: params['paymentMethod'] ?? params['payementWay'],
            amount: params['amount'] ?? params['total'],
            invoiceUrl: params['invoiceUrl'],
          );
        },
      ),
      GoRoute(
        path: '/payment/failure',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          return FailurePage(
            orderId: params['orderId'],
            date: params['date'],
            paymentMethod: params['paymentMethod'] ?? params['payementWay'],
            amount: params['amount'] ?? params['total'],
            failureReason:
                params['reason'] ?? params['error'] ?? 'Erreur inconnue',
          );
        },
      ),

      // Deep link routes for custom scheme (amerli://success and amerli://failure)
      // Note: For custom scheme amerli://success, go_router sees path as "/" with host="success"
      // So we need a special handler that checks the URI scheme and host
      GoRoute(
        path: '/success',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          // ignore: avoid_print
          print('✅ Building SuccessPage with params: $params');
          return SuccessPage(
            orderId: params['orderId'],
            date: params['date'],
            paymentMethod: params['paymentMethod'] ?? params['payementWay'],
            amount: params['amount'] ?? params['total'],
            invoiceUrl: params['invoiceUrl'],
          );
        },
      ),
      GoRoute(
        path: '/failure',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          // ignore: avoid_print
          print('❌ Building FailurePage with params: $params');
          return FailurePage(
            orderId: params['orderId'],
            date: params['date'],
            paymentMethod: params['paymentMethod'] ?? params['payementWay'],
            amount: params['amount'] ?? params['total'],
            failureReason:
                params['reason'] ?? params['error'] ?? 'Erreur inconnue',
          );
        },
      ),
    ],
  );
}
