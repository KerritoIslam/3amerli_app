import 'package:amerli_app/core/dio/api_service.dart';
import '../models/order_model.dart';

class OrdersRemoteDataSource {
  final ApiService apiService;

  OrdersRemoteDataSource({required this.apiService});

  Future<List<OrderModel>> fetchOrders({int page = 1, int pageSize = 50, String? query}) async {
    final qp = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (query != null) qp['q'] = query;
    final response = await apiService.get('/orders', queryParameters: qp);
    final List<dynamic> list = response.data as List<dynamic>;
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> createOrder(Map<String, dynamic> payload) async {
    final response = await apiService.post('/orders', data: payload);
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
