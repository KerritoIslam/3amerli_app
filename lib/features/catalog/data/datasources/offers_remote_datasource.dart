import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/core/network/error_message_extractor.dart';
import '../models/offer_model.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class OffersRemoteDataSource {
  final ApiService apiService;

  OffersRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  Future<List<OfferModel>> fetchOffers(
      {int page = 1, int pageSize = 50}) async {
    try {
      final resp = await apiService
          .get('/offers', queryParameters: {'page': page, 'limit': pageSize});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data is Map
            ? (resp.data['data'] as List<dynamic>?) ?? []
            : (resp.data as List<dynamic>?) ?? [];
        return list
            .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
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
          'Dio error fetchOffers - status: $status, serverResponse: $serverResp',
          name: 'OffersRemoteDataSource',
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

  Future<OfferModel> createOffer(Map<String, dynamic> payload) async {
    try {
      final resp = await apiService.post('/offers', data: payload);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return OfferModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error createOffer - status: $status, serverResponse: $serverResp',
          name: 'OffersRemoteDataSource',
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

  Future<void> deleteOffer(int id) async {
    try {
      final resp = await apiService.client.delete('/offers/$id');
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error deleteOffer - status: $status, serverResponse: $serverResp',
          name: 'OffersRemoteDataSource',
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
