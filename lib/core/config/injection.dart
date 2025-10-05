import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../features/catalog/app/bloc/catalog_bloc.dart';
import '../../features/catalog/repository/catalog_repository_impl.dart';
import '../../features/catalog/data/datasources/catalog_remote_datasource.dart';
import '../../core/dio/api_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => ApiService(dio: sl<Dio>()));

  // Data sources
  sl.registerLazySingleton(() => CatalogRemoteDataSource(apiService: sl<ApiService>()));

  // Repositories
  sl.registerLazySingleton(() => CatalogRepositoryImpl(remoteDataSource: sl<CatalogRemoteDataSource>()));

  // Blocs
  sl.registerFactory(() => CatalogBloc(repository: sl<CatalogRepositoryImpl>()));
}
