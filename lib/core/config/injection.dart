
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

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
import '../../features/catalog/repository/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/data/datasources/favorites_remote_datasource.dart';
import '../../features/catalog/repository/favorites_repository_impl.dart';
import '../../features/catalog/domain/repositories/favorites_repository.dart';
import '../../features/catalog/data/datasources/categories_remote_datasource.dart';
import '../../features/catalog/repository/categories_repository_impl.dart';
import '../../features/catalog/domain/repositories/categories_repository.dart';
import '../../features/catalog/app/bloc/favorites_bloc.dart';
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
import '../../features/catalog/data/datasources/catalog_remote_datasource.dart';
import '../../core/dio/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  // Create Dio and ApiService with placeholder values; replace baseUrl/jwtToken later
  sl.registerLazySingleton(() => Dio());
  const placeholderBaseUrl = 'https://api.example.com';
  const placeholderJwt = 'eyJhbGciOiJI...REPLACE_ME'; // TODO: replace with real token / secure storage
  sl.registerLazySingleton(() => ApiService(dio: sl<Dio>(), baseUrl: placeholderBaseUrl, jwtToken: placeholderJwt));

  // Storage - SharedPreferences and SecureStorage
  // Initialize SharedPreferences once and register it
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Register LocalStorage wrapper
  final localStorage = LocalStorage(prefs);
  sl.registerLazySingleton<LocalStorage>(() => localStorage);

  // Register secure storage wrapper
  sl.registerLazySingleton(() => SecureStorage(storage: const FlutterSecureStorage()));

  // Register Settings (depends on SharedPreferences)
  final settings = Settings(prefs);
  sl.registerLazySingleton<Settings>(() => settings);

  // (demo AuthController removed; using AuthBloc instead)

  // Data sources
  sl.registerLazySingleton(() => CatalogRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(() => FavoritesRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(() => OffersRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(() => CategoriesRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(() => OrdersRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(() => NotificationsRemoteDataSource(apiService: sl<ApiService>()));

  sl.registerLazySingleton(() => PaymentsRemoteDataSource(apiService: sl<ApiService>()));
  sl.registerLazySingleton(() => ProfileRemoteDataSourceImpl(apiService: sl<ApiService>()));

  // Repositories
  sl.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(remoteDataSource: sl<CatalogRemoteDataSource>()));
  sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(remoteDataSource: sl<FavoritesRemoteDataSource>()));
  sl.registerLazySingleton<CategoriesRepository>(() => CategoriesRepositoryImpl(remoteDataSource: sl<CategoriesRemoteDataSource>()));
  sl.registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(remoteDataSource: sl<OrdersRemoteDataSource>()));
  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(remoteDataSource: sl<NotificationsRemoteDataSource>()));
  sl.registerLazySingleton<OffersRepository>(() => OffersRepositoryImpl(remoteDataSource: sl<OffersRemoteDataSource>()));
  sl.registerLazySingleton<PaymentsRepository>(() => PaymentsRepositoryImpl(remoteDataSource: sl<PaymentsRemoteDataSource>()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remoteDataSource: sl<ProfileRemoteDataSourceImpl>()));

  // Blocs
  // Make CatalogBloc app-scoped (singleton) so its state is preserved across routes
  sl.registerLazySingleton<CatalogBloc>(() => CatalogBloc(repository: sl<CatalogRepository>()));
  sl.registerFactory(() => FavoritesBloc(repository: sl<FavoritesRepository>()));
  sl.registerFactory(() => CategoriesBloc(repository: sl<CategoriesRepository>()));
  // Feature Blocs (make some app-scoped singletons)
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc());
  // Cart should be app-scoped to preserve user selections across routes
  sl.registerLazySingleton<CartBloc>(() => CartBloc());
  sl.registerFactory(() => ProfileBloc(repository: sl<ProfileRepository>()));
  sl.registerFactory(() => OrdersBloc(repository: sl<OrdersRepository>()));
  sl.registerFactory(() => PaymentsBloc(repository: sl<PaymentsRepository>()));
  sl.registerFactory(() => DeliveryBloc());
  sl.registerLazySingleton<NotificationsBloc>(() => NotificationsBloc());
  sl.registerLazySingleton<OffersBloc>(() => OffersBloc(repository: sl<OffersRepository>()));
  sl.registerFactory(() => AdminBloc());
}
