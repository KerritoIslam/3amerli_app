import 'package:amerli_app/features/catalog/domain/entities/favorite.dart';

abstract class FavoritesRepository {
  Future<List<Favorite>> getFavorites({int page = 1, int pageSize = 50});
  /// Toggle favorite for a product. Older APIs returned Favorite objects;
  /// backend currently exposes a toggle endpoint returning a boolean, so
  /// repository provides add/remove as void operations that call toggle.
  Future<void> addFavorite({required int userId, required int productId});
  Future<void> removeFavorite(int productId);
}
