import 'package:amerli_app/features/catalog/domain/entities/favorite.dart';
import 'package:amerli_app/features/catalog/domain/repositories/favorites_repository.dart';
import 'package:amerli_app/features/catalog/data/datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Favorite>> getFavorites({int page = 1, int pageSize = 50}) async {
    final models = await remoteDataSource.fetchFavorites(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Favorite> addFavorite({required int userId, required int productId}) async {
    final model = await remoteDataSource.addFavorite(userId: userId, productId: productId);
    return model.toEntity();
  }

  @override
  Future<void> removeFavorite(int id) async {
    await remoteDataSource.removeFavorite(id);
  }
}
