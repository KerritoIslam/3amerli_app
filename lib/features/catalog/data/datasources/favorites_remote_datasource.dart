import 'package:amerli_app/core/dio/api_service.dart';
import '../models/favorite_model.dart';

class FavoritesRemoteDataSource {
  final ApiService apiService;

  FavoritesRemoteDataSource({required this.apiService});

  Future<List<FavoriteModel>> fetchFavorites({int page = 1, int pageSize = 50}) async {
    final response = await apiService.get('/favorites', queryParameters: {'page': page, 'pageSize': pageSize});
    final List<dynamic> list = response.data as List<dynamic>;
    return list.map((e) => FavoriteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FavoriteModel> addFavorite({required int userId, required int productId}) async {
    final response = await apiService.post('/favorites', data: {'userId': userId, 'productId': productId});
    return FavoriteModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> removeFavorite(int id) async {
    await apiService.delete('/favorites/$id');
  }
}
