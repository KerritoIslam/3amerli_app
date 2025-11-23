import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../core/error/global_error_handler.dart';

import '../../features/catalog/app/bloc/catalog_bloc.dart';
import '../../features/auth/app/bloc/auth_bloc.dart';
// ...existing imports
import '../../features/orders/app/bloc/orders_bloc.dart';
import '../../features/delivery/app/bloc/delivery_bloc.dart';
import '../../features/notifications/app/bloc/notifications_bloc.dart';
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/repository/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/catalog/data/datasources/offers_remote_datasource.dart';
import '../../features/catalog/repository/offers_repository_impl.dart';
import '../../features/catalog/domain/repositories/offers_repository.dart';
import '../../features/catalog/app/bloc/offers_bloc.dart';
import '../../features/admin/app/bloc/admin_bloc.dart';
import '../../features/admin/dashboard/app/bloc/dashboard_bloc.dart';
import '../../features/admin/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/admin/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/admin/orders/app/bloc/admin_orders_bloc.dart';
import '../../features/admin/orders/data/repositories/admin_orders_repository_impl.dart';
import '../../features/admin/orders/domain/repositories/admin_orders_repository.dart';
import '../../features/admin/users/app/bloc/admin_users_bloc.dart';
import '../../features/admin/users/data/repositories/admin_users_repository_impl.dart';
import '../../features/admin/users/domain/repositories/admin_users_repository.dart';
import '../../features/admin/products/app/bloc/admin_products_bloc.dart';
import '../../features/admin/products/data/repositories/admin_products_repository_impl.dart';
import '../../features/admin/products/domain/repositories/admin_products_repository.dart';
import '../../features/admin/categories/app/bloc/admin_categories_bloc.dart';
import '../../features/admin/categories/data/repositories/admin_categories_repository_impl.dart';
import '../../features/admin/categories/domain/repositories/admin_categories_repository.dart';
import '../../features/admin/brands/data/repositories/admin_brands_repository_impl.dart';
import '../../features/admin/brands/domain/repositories/admin_brands_repository.dart';
import '../../features/catalog/repository/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/data/datasources/favorites_remote_datasource.dart';
import '../../features/catalog/repository/favorites_repository_impl.dart';
import '../../features/catalog/domain/repositories/favorites_repository.dart';
import '../../features/catalog/data/datasources/categories_remote_datasource.dart';
import '../../features/catalog/data/datasources/brands_remote_datasource.dart';
import '../../features/catalog/domain/repositories/brands_repository.dart';
import '../../features/catalog/repository/brands_repository_impl.dart';
import '../../features/catalog/app/bloc/brands_bloc.dart';
import '../../features/catalog/repository/categories_repository_impl.dart';
import '../../features/catalog/domain/repositories/categories_repository.dart';
import '../../features/catalog/app/bloc/favorites_bloc.dart';
// Favorits feature (mocked favorites products list)
import 'package:amerli_app/features/favorits/app/bloc/favorits_bloc.dart'
    as fav_feature;
import 'package:amerli_app/features/favorits/data/datasources/favorits_remote_datasource.dart'
    as fav_feature;
import 'package:amerli_app/features/favorits/data/repositories/favorits_repository_impl.dart'
    as fav_feature;
import 'package:amerli_app/features/favorits/domain/repositories/favorits_repository.dart'
    as fav_feature;
import '../../features/catalog/app/bloc/categories_bloc.dart';
import '../../features/cart/app/bloc/cart_bloc.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/repository/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
// ...existing imports
import '../../features/payments/data/datasources/payments_remote_datasource.dart';
import '../../features/payments/repository/payments_repository_impl.dart';
import '../../features/payments/domain/repositories/payments_repository.dart';
import '../../features/payments/app/bloc/payments_bloc.dart';
import 'package:amerli_app/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:amerli_app/features/auth/repository/profile_repository_impl.dart';
import 'package:amerli_app/features/auth/domain/repositories/profile_repository.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_bloc.dart';
import 'package:amerli_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:amerli_app/features/auth/data/datasources/profile_local_datasource.dart';
import 'package:amerli_app/features/auth/repository/auth_repository_impl.dart';
import '../../features/catalog/data/datasources/catalog_remote_datasource.dart';
import '../../core/dio/api_service.dart';
import '../../core/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../../utils/constants/app_constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  // Create Dio and ApiService
  sl.registerLazySingleton(() => Dio(BaseOptions(
        validateStatus: (status) =>
            status != null && status < 500, // Don't throw on 4xx errors
      )));
  // Use a single source of truth for the API base url
  const baseUrl = AppConstants.apiBaseUrl;
  // Register AuthService (uses flutter_secure_storage internally)
  sl.registerLazySingleton(() => AuthService());
  sl.registerLazySingleton(() => ApiService(
      dio: sl<Dio>(),
      baseUrl: baseUrl,
      authService: sl<AuthService>(),
      globalErrorHandler: sl<GlobalErrorHandler>()));

  // Global Error Handler
  sl.registerLazySingleton(() => GlobalErrorHandler());

  // Storage - SharedPreferences and SecureStorage
  // Initialize SharedPreferences once and register it
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Register LocalStorage wrapper
  final localStorage = LocalStorage(prefs);
  sl.registerLazySingleton<LocalStorage>(() => localStorage);

  // Register secure storage wrapper
  sl.registerLazySingleton(
      () => SecureStorage(storage: const FlutterSecureStorage()));

  // Register Settings (depends on SharedPreferences)
  final settings = Settings(prefs);
  sl.registerLazySingleton<Settings>(() => settings);

  // (demo AuthController removed; using AuthBloc instead)

  // Data sources
  sl.registerLazySingleton(
      () => CatalogRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(
      () => FavoritesRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(
      () => OffersRemoteDataSource(apiService: sl<ApiService>()));
  // Favorits
  sl.registerLazySingleton<fav_feature.FavoritsRemoteDataSource>(
      () => fav_feature.FavoritsRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(
      () => CategoriesRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(
      () => BrandsRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(
      () => OrdersRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(
      () => NotificationsRemoteDataSource(apiService: sl<ApiService>()));

  sl.registerLazySingleton(
      () => PaymentsRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(
      () => ProfileRemoteDataSourceImpl(apiService: sl<ApiService>()));
  // Auth feature datasources & repository
  sl.registerLazySingleton(
      () => AuthRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(() => ProfileLocalDataSource());
  sl.registerLazySingleton(() => AuthRepositoryImpl(
      remote: sl<AuthRemoteDataSource>(),
      authService: sl<AuthService>(),
      local: sl<ProfileLocalDataSource>()));

  // Repositories
  sl.registerLazySingleton<CatalogRepository>(() =>
      CatalogRepositoryImpl(remoteDataSource: sl<CatalogRemoteDataSource>()));
  sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(
      remoteDataSource: sl<FavoritesRemoteDataSource>()));
  sl.registerLazySingleton<CategoriesRepository>(() => CategoriesRepositoryImpl(
      remoteDataSource: sl<CategoriesRemoteDataSource>()));
  sl.registerLazySingleton<BrandsRepository>(() =>
      BrandsRepositoryImpl(remoteDataSource: sl<BrandsRemoteDataSource>()));
  sl.registerLazySingleton<OrdersRepository>(() =>
      OrdersRepositoryImpl(remoteDataSource: sl<OrdersRemoteDataSource>()));
  sl.registerLazySingleton<NotificationsRepository>(() =>
      NotificationsRepositoryImpl(
          remoteDataSource: sl<NotificationsRemoteDataSource>()));
  sl.registerLazySingleton<OffersRepository>(() =>
      OffersRepositoryImpl(remoteDataSource: sl<OffersRemoteDataSource>()));
  sl.registerLazySingleton<PaymentsRepository>(() =>
      PaymentsRepositoryImpl(remoteDataSource: sl<PaymentsRemoteDataSource>()));
  // Favorits
  sl.registerLazySingleton<fav_feature.FavoritsRepository>(() =>
      fav_feature.FavoritsRepositoryImpl(
          remote: sl<fav_feature.FavoritsRemoteDataSource>()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSourceImpl>()));

  // Blocs
  // Make CatalogBloc app-scoped (singleton) so its state is preserved across routes
  sl.registerLazySingleton<CatalogBloc>(
      () => CatalogBloc(repository: sl<CatalogRepository>()));
  sl.registerFactory(
      () => FavoritesBloc(repository: sl<FavoritesRepository>()));
  sl.registerFactory(
      () => CategoriesBloc(repository: sl<CategoriesRepository>()));
  // Feature Blocs (make some app-scoped singletons)
  sl.registerLazySingleton<AuthBloc>(
      () => AuthBloc(authService: sl<AuthService>()));
  // Cart should be app-scoped to preserve user selections across routes
  sl.registerLazySingleton<CartBloc>(() => CartBloc());
  // Favorits Bloc
  sl.registerFactory<fav_feature.FavoritsBloc>(() => fav_feature.FavoritsBloc(
      repository: sl<fav_feature.FavoritsRepository>()));
  sl.registerFactory(() => ProfileBloc(repository: sl<ProfileRepository>()));
  sl.registerLazySingleton<OrdersBloc>(
      () => OrdersBloc(repository: sl<OrdersRepository>()));
  sl.registerFactory(() => PaymentsBloc(repository: sl<PaymentsRepository>()));
  sl.registerFactory(() => DeliveryBloc());
  sl.registerLazySingleton<NotificationsBloc>(
      () => NotificationsBloc(repository: sl<NotificationsRepository>()));
  sl.registerLazySingleton<OffersBloc>(
      () => OffersBloc(repository: sl<OffersRepository>()));
  sl.registerFactory(() => AdminBloc());
  // Admin features
  sl.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(apiService: sl<ApiService>()));
  sl.registerFactory(() => DashboardBloc(sl<DashboardRepository>()));
  sl.registerLazySingleton<AdminOrdersRepository>(
      () => AdminOrdersRepositoryImpl(apiService: sl<ApiService>()));
  sl.registerFactory(() => AdminOrdersBloc(sl<AdminOrdersRepository>()));
  sl.registerLazySingleton<AdminUsersRepository>(
      () => AdminUsersRepositoryImpl(apiService: sl<ApiService>()));
  sl.registerFactory(
      () => AdminUsersBloc(repository: sl<AdminUsersRepository>()));
  sl.registerLazySingleton<AdminProductsRepository>(
      () => AdminProductsRepositoryImpl(apiService: sl<ApiService>()));
  sl.registerLazySingleton<AdminProductsBloc>(
      () => AdminProductsBloc(sl<AdminProductsRepository>()));
  sl.registerLazySingleton<AdminCategoriesRepository>(
      () => AdminCategoriesRepositoryImpl(apiService: sl<ApiService>()));
  sl.registerFactory(
      () => AdminCategoriesBloc(sl<AdminCategoriesRepository>()));
  sl.registerLazySingleton<AdminBrandsRepository>(
      () => AdminBrandsRepositoryImpl(apiService: sl<ApiService>()));
  // Brands feature
  sl.registerFactory(() => BrandsBloc(repository: sl<BrandsRepository>()));
}
