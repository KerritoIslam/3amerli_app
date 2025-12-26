import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/core/network/error_message_extractor.dart';
import '../models/category_model.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class CategoriesRemoteDataSource {
  final ApiService apiService;

  CategoriesRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  /// GET /categories/main-categories
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final resp = await apiService.get('/categories/main-categories');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data as List<dynamic>;
        return list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
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
          'Dio error fetchCategories - status: $status, serverResponse: $serverResp',
          name: 'CategoriesRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    } catch (e, st) {
      developer.log('Unexpected error while fetching categories: $e',
          name: 'CategoriesRemoteDataSource',
          error: e,
          stackTrace: st as StackTrace?);
      throw ApiException('Unexpected error while fetching categories: $e');
    }
  }

  /// POST /categories/categories
  Future<CategoryModel> createCategory(
      {required String label, int? parentId}) async {
    try {
      final resp = await apiService.post('/categories',
          data: {'label': label, if (parentId != null) 'parentId': parentId});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return CategoryModel.fromJson(
            Map<String, dynamic>.from(resp.data as Map));
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error createCategory - status: $status, serverResponse: $serverResp',
          name: 'CategoriesRemoteDataSource',
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

  /// PUT /categories/categories/{id}
  Future<void> updateCategory(int id, {String? label, int? parentId}) async {
    try {
      final resp = await apiService.client.put('/categories/$id',
          data: {'label': label, if (parentId != null) 'parentId': parentId});
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error updateCategory - status: $status, serverResponse: $serverResp',
          name: 'CategoriesRemoteDataSource',
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

  /// DELETE /categories/categories/{id}
  Future<void> deleteCategory(int id) async {
    try {
      final resp = await apiService.client.delete('/categories/$id');
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error deleteCategory - status: $status, serverResponse: $serverResp',
          name: 'CategoriesRemoteDataSource',
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

  /// GET /categories/categories/{id}/children
  Future<List<CategoryModel>> fetchChildren(int parentId) async {
    try {
      final resp = await apiService.get('/categories/$parentId/children');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data as List<dynamic>;
        return list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
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
          'Dio error fetchChildren - status: $status, serverResponse: $serverResp',
          name: 'CategoriesRemoteDataSource',
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

  /// GET /categories/subcategories/all
  Future<List<CategoryModel>> fetchAllSubCategories() async {
    try {
      final resp = await apiService.get('/categories/subcategories/all');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data as List<dynamic>;
        return list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
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
          'Dio error fetchAllSubCategories - status: $status, serverResponse: $serverResp',
          name: 'CategoriesRemoteDataSource',
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
