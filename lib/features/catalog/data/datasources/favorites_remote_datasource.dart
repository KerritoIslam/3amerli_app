import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/core/network/error_message_extractor.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../models/favorite_model.dart';

class FavoritesRemoteDataSource {
  final ApiService apiService;

  FavoritesRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  /// GET /products/favorite/all
  Future<List<FavoriteModel>> fetchFavorites(
      {int page = 1, int pageSize = 50}) async {
    try {
      final resp = await apiService.get('/products/favorite/all',
          queryParameters: {'page': page, 'limit': pageSize});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?) ?? [];
        return items
            .map((e) => FavoriteModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error fetchFavorites - status: $status, serverResponse: $serverResp',
          name: 'FavoritesRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  /// POST /products/{id}/toggle-favorite
  Future<bool> toggleFavorite(int productId) async {
    try {
      final resp =
          await apiService.post('/products/$productId/toggle-favorite');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        return data['isLoved'] as bool? ?? false;
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error toggleFavorite - status: $status, serverResponse: $serverResp',
          name: 'FavoritesRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }
}
