import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../models/favorite_model.dart';

class FavoritesRemoteDataSource {
  final ApiService apiService;

  FavoritesRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) => status != null && status >= 200 && status < 300;

  /// GET /products/favorite/all
  Future<List<FavoriteModel>> fetchFavorites({int page = 1, int pageSize = 50}) async {
    try {
      final resp = await apiService.get('/products/favorite/all', queryParameters: {'page': page, 'limit': pageSize});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?) ?? [];
        return items.map((e) => FavoriteModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch favorites';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching favorites';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error fetchFavorites - status: $status, serverResponse: $serverResp', name: 'FavoritesRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }

  /// POST /products/{id}/toggle-favorite
  Future<bool> toggleFavorite(int productId) async {
    try {
      final resp = await apiService.post('/products/$productId/toggle-favorite');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        return data['isLoved'] as bool? ?? false;
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to toggle favorite';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while toggling favorite';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error toggleFavorite - status: $status, serverResponse: $serverResp', name: 'FavoritesRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }
}
