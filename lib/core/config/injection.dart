
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/catalog/app/bloc/catalog_bloc.dart';
import '../../features/auth/app/bloc/auth_bloc.dart';
import '../../features/orders/app/bloc/orders_bloc.dart';
import '../../features/payments/app/bloc/payments_bloc.dart';
import '../../features/delivery/app/bloc/delivery_bloc.dart';
import '../../features/notifications/app/bloc/notifications_bloc.dart';
import '../../features/admin/app/bloc/admin_bloc.dart';
import '../../features/catalog/repository/catalog_repository_impl.dart';
import '../../features/catalog/data/datasources/catalog_remote_datasource.dart';
import '../../core/dio/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => ApiService(dio: sl<Dio>()));

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

  // Repositories
  sl.registerLazySingleton(() => CatalogRepositoryImpl(remoteDataSource: sl<CatalogRemoteDataSource>()));

  // Blocs
  // Make CatalogBloc app-scoped (singleton) so its state is preserved across routes
  sl.registerLazySingleton<CatalogBloc>(() => CatalogBloc(repository: sl<CatalogRepositoryImpl>()));
  // Feature Blocs (make some app-scoped singletons)
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc());
  sl.registerFactory(() => OrdersBloc());
  sl.registerFactory(() => PaymentsBloc());
  sl.registerFactory(() => DeliveryBloc());
  sl.registerLazySingleton<NotificationsBloc>(() => NotificationsBloc());
  sl.registerFactory(() => AdminBloc());
}
