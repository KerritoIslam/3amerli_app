import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/core/network/error_message_extractor.dart';
import '../models/brand_model.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class BrandsRemoteDataSource {
  final ApiService apiService;

  BrandsRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  /// GET /products/brands
  Future<List<BrandModel>> fetchBrands() async {
    try {
      final resp = await apiService.get('/brands');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data as List<dynamic>;
        return list
            .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
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
          'Dio error fetchBrands - status: $status, serverResponse: $serverResp',
          name: 'BrandsRemoteDataSource',
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

  /// POST /products/brands
  Future<BrandModel> createBrand(String label) async {
    try {
      final resp = await apiService.post('/brands', data: {'label': label});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return BrandModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error createBrand - status: $status, serverResponse: $serverResp',
          name: 'BrandsRemoteDataSource',
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

  /// PUT /products/brands/{id}
  Future<BrandModel> updateBrand(int id, String label) async {
    try {
      final resp = await apiService.put('/brands/$id', data: {'label': label});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return BrandModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error updateBrand - status: $status, serverResponse: $serverResp',
          name: 'BrandsRemoteDataSource',
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

  /// DELETE /products/brands/{id}
  Future<void> deleteBrand(int id) async {
    try {
      final resp = await apiService.client.delete('/brands/$id');
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error deleteBrand - status: $status, serverResponse: $serverResp',
          name: 'BrandsRemoteDataSource',
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
