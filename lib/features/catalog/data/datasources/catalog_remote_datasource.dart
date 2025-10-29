import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/features/catalog/data/models/product_model.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class CatalogRemoteDataSource {
  final ApiService apiService;

  CatalogRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) => status != null && status >= 200 && status < 300;

  /// Calls GET /products/all?page=&limit=&search=&categoryIds=
  Future<List<ProductModel>> fetchProducts({int page = 1, int pageSize = 50, String? query, List<int>? categoryIds}) async {
    try {
      final qp = <String, dynamic>{'page': page, 'limit': pageSize};
      if (query != null && query.isNotEmpty) qp['search'] = query;
  if (categoryIds != null && categoryIds.isNotEmpty) qp['categoryIds'] = categoryIds;

      final resp = await apiService.get('/products/all', queryParameters: qp);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?) ?? [];
        return items.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
      }

      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch products';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching products';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error fetchProducts - status: $status, serverResponse: $serverResp', name: 'CatalogRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    } catch (e, st) {
      developer.log('Unexpected error while fetching products: $e', name: 'CatalogRemoteDataSource', error: e, stackTrace: st as StackTrace?);
      throw ApiException('Unexpected error while fetching products: $e');
    }
  }

  Future<ProductModel> fetchProductById(int id) async {
    try {
      final resp = await apiService.get('/products/$id');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return ProductModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch product';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching product';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error fetchProductById - status: $status, serverResponse: $serverResp', name: 'CatalogRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }
}
