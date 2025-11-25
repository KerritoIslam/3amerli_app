import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/core/network/error_message_extractor.dart';
import '../models/order_model.dart';
import '../models/create_order_result.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class OrdersRemoteDataSource {
  final ApiService apiService;

  OrdersRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  /// GET /order/all
  Future<List<OrderModel>> fetchOrders(
      {int page = 1, int pageSize = 10}) async {
    try {
      final resp = await apiService.get('/order/all',
          queryParameters: {'page': page, 'limit': pageSize});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        // The response body has a 'data' field which is a list of orders
        final items = (data['data'] as List<dynamic>?) ?? [];
        return items
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final errorMsg = extractErrorMessage(resp.data);
      throw ApiException(errorMsg,
          statusCode: resp.statusCode, serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error fetchOrders - status: $status, serverResponse: $serverResp',
          name: 'OrdersRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      final errorMsg = extractErrorMessage(serverResp);
      throw ApiException(errorMsg,
          statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
  }

  /// POST /order
  Future<CreateOrderResult> createOrder(Map<String, dynamic> payload) async {
    try {
      final resp = await apiService.post('/order', data: payload);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final result = CreateOrderResult.fromJson(
            Map<String, dynamic>.from(resp.data as Map));
        developer.log('createOrder: checkoutUrl=${result.checkoutUrl}',
            name: 'OrdersRemoteDataSource');
        return result;
      }
      final errorMsg = extractErrorMessage(resp.data);
      throw ApiException(errorMsg,
          statusCode: resp.statusCode, serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error createOrder - status: $status, serverResponse: $serverResp',
          name: 'OrdersRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      final errorMsg = extractErrorMessage(serverResp);
      throw ApiException(errorMsg,
          statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
  }

  /// GET /order/{orderId}/products
  Future<List<Map<String, dynamic>>> getOrderProducts(int orderId) async {
    try {
      final resp = await apiService.get('/order/$orderId/products');
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data as List<dynamic>;
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      final errorMsg = extractErrorMessage(resp.data);
      throw ApiException(errorMsg,
          statusCode: resp.statusCode, serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error getOrderProducts - status: $status, serverResponse: $serverResp',
          name: 'OrdersRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      final errorMsg = extractErrorMessage(serverResp);
      throw ApiException(errorMsg,
          statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
  }
}
