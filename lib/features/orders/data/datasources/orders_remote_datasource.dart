import 'dart:convert';

import 'package:amerli_app/core/dio/api_service.dart';
import '../models/order_model.dart';

class OrdersRemoteDataSource {
  final ApiService apiService;

  OrdersRemoteDataSource({required this.apiService});

  Future<List<OrderModel>> fetchOrders({int page = 1, int pageSize = 50, String? query}) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (query != null) qp['q'] = query;
    await Future.delayed(const Duration(seconds: 2));
    final sample = '''[
      {"id":1, "userId":1, "totalAmount":1200.0, "status":"pending", "createdAt":"2025-10-10T00:00:00Z", "items": []}
    ]''';
    final List<dynamic> list = json.decode(sample) as List<dynamic>;
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> createOrder(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(seconds: 2));
    // Return payload-mirrored order with mocked id
    final result = {'id': 999, ...payload};
    return OrderModel.fromJson(result);
  }
}
