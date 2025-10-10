import 'dart:convert';

import 'package:amerli_app/core/dio/api_service.dart';
import '../models/favorite_model.dart';

class FavoritesRemoteDataSource {
  final ApiService apiService;

  FavoritesRemoteDataSource({required this.apiService});

  Future<List<FavoriteModel>> fetchFavorites({int page = 1, int pageSize = 50}) async {
    await Future.delayed(const Duration(seconds: 2));
    final sample = '''[
      {"id": 1, "userId": 1, "productId": 2},
      {"id": 2, "userId": 1, "productId": 3}
    ]''';
    final List<dynamic> list = json.decode(sample) as List<dynamic>;
    return list.map((e) => FavoriteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FavoriteModel> addFavorite({required int userId, required int productId}) async {
    await Future.delayed(const Duration(seconds: 2));
    // return the created favorite with a mocked id
    return FavoriteModel(id: 999, userId: userId, productId: productId);
  }

  Future<void> removeFavorite(int id) async {
    await Future.delayed(const Duration(seconds: 2));
    return;
  }
}
