import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import '../models/order_model.dart';
import '../models/create_order_result.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class OrdersRemoteDataSource {
  final ApiService apiService;

  OrdersRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) => status != null && status >= 200 && status < 300;

  /// GET /order/all
  Future<List<OrderModel>> fetchOrders({int page = 1, int pageSize = 50}) async {
    try {
      final resp = await apiService.get('/order/all', queryParameters: {'page': page, 'limit': pageSize});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final data = resp.data as Map<String, dynamic>;
        final items = (data['data'] as List<dynamic>?) ?? [];
        return items.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch orders';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching orders';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error fetchOrders - status: $status, serverResponse: $serverResp', name: 'OrdersRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }

  /// POST /order
  Future<CreateOrderResult> createOrder(Map<String, dynamic> payload) async {
    try {
      final resp = await apiService.post('/order', data: payload);
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final result = CreateOrderResult.fromJson(Map<String, dynamic>.from(resp.data as Map));
        developer.log('createOrder: checkoutUrl=${result.checkoutUrl}', name: 'OrdersRemoteDataSource');
        return result;
      }
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to create order';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while creating order';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error createOrder - status: $status, serverResponse: $serverResp', name: 'OrdersRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
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
      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to fetch order products';
      throw ApiException(msg, statusCode: resp.statusCode);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while fetching order products';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error getOrderProducts - status: $status, serverResponse: $serverResp', name: 'OrdersRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true);
    }
  }
}
