import 'package:amerli_app/features/catalog/domain/entities/favorite.dart';

abstract class FavoritesRepository {
  Future<List<Favorite>> getFavorites({int page = 1, int pageSize = 50});
  Future<Favorite> addFavorite({required int userId, required int productId});
  Future<void> removeFavorite(int id);
}
