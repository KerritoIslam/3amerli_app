import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import '../models/brand_model.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class BrandsRemoteDataSource {
  final ApiService apiService;

  BrandsRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) => status != null && status >= 200 && status < 300;

  /// GET /products/brands
  Future<List<BrandModel>> fetchBrands() async {
    try {
      final resp = await apiService.get('/brands');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data as List<dynamic>;
        return list.map((e) => BrandModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch brands';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching brands';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error fetchBrands - status: $status, serverResponse: $serverResp', name: 'BrandsRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }

  /// POST /products/brands
  Future<BrandModel> createBrand(String label) async {
    try {
      final resp = await apiService.post('/brands', data: {'label': label});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return BrandModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to create brand';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while creating brand';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error createBrand - status: $status, serverResponse: $serverResp', name: 'BrandsRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }

  /// PUT /products/brands/{id}
  Future<BrandModel> updateBrand(int id, String label) async {
    try {
      final resp = await apiService.put('/brands/$id', data: {'label': label});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return BrandModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to update brand';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while updating brand';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error updateBrand - status: $status, serverResponse: $serverResp', name: 'BrandsRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }

  /// DELETE /products/brands/{id}
  Future<void> deleteBrand(int id) async {
    try {
      final resp = await apiService.client.delete('/brands/$id');
      if (_isSuccess(resp.statusCode)) return;
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to delete brand';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while deleting brand';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error deleteBrand - status: $status, serverResponse: $serverResp', name: 'BrandsRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }
}
