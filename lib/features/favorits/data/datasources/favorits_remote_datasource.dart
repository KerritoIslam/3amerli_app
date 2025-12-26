import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/core/network/error_message_extractor.dart';
import 'package:amerli_app/features/catalog/data/models/product_model.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class FavoritsRemoteDataSource {
  final ApiService apiService;

  FavoritsRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  Future<List<ProductModel>> fetchFavoritProducts(
      {int page = 1, int pageSize = 20}) async {
    try {
      final resp = await apiService.get('/products/favorite/all',
          queryParameters: {'page': page, 'limit': pageSize});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?)?.map((e) {
              e["isLoved"] = true;
              return ProductModel.fromJson(e);
            }).toList() ??
            [];

        return items;
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error fetchFavoritProducts - status: $status, serverResponse: $serverResp',
          name: 'FavoritsRemoteDataSource',
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
