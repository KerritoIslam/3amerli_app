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
  Future<void> addFavorite({required int userId, required int productId}) async {
    // Backend exposes a toggle endpoint for favorites; call it to add.
    await remoteDataSource.toggleFavorite(productId);
  }

  @override
  Future<void> removeFavorite(int productId) async {
    // Use the same toggle endpoint to remove the favorite.
    await remoteDataSource.toggleFavorite(productId);
  }
}
