import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import '../models/offer_model.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class OffersRemoteDataSource {
  final ApiService apiService;

  OffersRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) => status != null && status >= 200 && status < 300;

  Future<List<OfferModel>> fetchOffers({int page = 1, int pageSize = 50}) async {
    try {
      final resp = await apiService.get('/offers', queryParameters: {'page': page, 'limit': pageSize});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data is Map ? (resp.data['data'] as List<dynamic>?) ?? [] : (resp.data as List<dynamic>?) ?? [];
        return list.map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch offers';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching offers';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error fetchOffers - status: $status, serverResponse: $serverResp', name: 'OffersRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }

  Future<OfferModel> createOffer(Map<String, dynamic> payload) async {
    try {
      final resp = await apiService.post('/offers', data: payload);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        return OfferModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to create offer';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while creating offer';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error createOffer - status: $status, serverResponse: $serverResp', name: 'OffersRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }

  Future<void> deleteOffer(int id) async {
    try {
      final resp = await apiService.client.delete('/offers/$id');
      if (_isSuccess(resp.statusCode)) return;
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to delete offer';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while deleting offer';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error deleteOffer - status: $status, serverResponse: $serverResp', name: 'OffersRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }
}
