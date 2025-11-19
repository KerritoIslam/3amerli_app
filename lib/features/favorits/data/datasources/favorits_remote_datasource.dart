import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/features/catalog/data/models/product_model.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class FavoritsRemoteDataSource {
  final ApiService apiService;

  FavoritsRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) => status != null && status >= 200 && status < 300;

  Future<List<ProductModel>> fetchFavoritProducts({int page = 1, int pageSize = 20}) async {
    try {
      final resp = await apiService.get('/products/favorite/all', queryParameters: {'page': page, 'limit': pageSize});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?) ?? [];
        return items.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch favorite products';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching favorite products';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error fetchFavoritProducts - status: $status, serverResponse: $serverResp', name: 'FavoritsRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }
}



