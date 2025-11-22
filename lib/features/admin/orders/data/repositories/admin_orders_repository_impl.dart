import 'package:amerli_app/core/dio/api_service.dart';
import '../../domain/entities/admin_order.dart';
import '../../domain/repositories/admin_orders_repository.dart';
import '../models/admin_order_model.dart';
import 'package:dio/dio.dart';

class AdminOrdersRepositoryImpl implements AdminOrdersRepository {
  final ApiService apiService;

  AdminOrdersRepositoryImpl({required this.apiService});

  List _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    if (data is Map && data['items'] is List) return data['items'] as List;
    return [];
  }

  @override
  Future<List<AdminOrder>> getAllOrders(
      {String? query, int page = 1, int limit = 20}) async {
    final qp = <String, dynamic>{};
    if (query != null && query.isNotEmpty) qp['search'] = query;
    qp['page'] = page;
    qp['limit'] = limit;
    final resp = await apiService.get('/order/admin/all', queryParameters: qp);
    final list = _extractList(resp.data);
    return list.map<AdminOrder>((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return AdminOrderModel.fromJson(map).toEntity();
    }).toList();
  }

  @override
  Future<AdminOrder> getOrderById(String orderId) async {
    final resp = await apiService.get('/order/$orderId/infos');
    // the admin app expects a full AdminOrder; try GET /order/{id}/products may return items only
    if (resp.data is Map) {
      final map = Map<String, dynamic>.from(resp.data as Map);
      // If API returns the full order under data or order, adjust accordingly
      final orderMap = map['order'] ?? map['data'] ?? map;

      // Inject ID if missing, as the /infos endpoint might not return it in the body
      if (orderMap['id'] == null && orderMap['orderId'] == null) {
        orderMap['id'] = orderId;
      }

      return AdminOrderModel.fromJson(Map<String, dynamic>.from(orderMap))
          .toEntity();
    }
    throw Exception('Unexpected order response');
  }

  @override
  Future<AdminOrder> updateOrderStatus(String orderId, String newStatus) async {
    final resp = await apiService
        .post('/order/$orderId/status', data: {'status': newStatus});
    if (resp.data is Map) {
      final map = Map<String, dynamic>.from(resp.data as Map);
      final orderMap = map['order'] ?? map['data'] ?? map;

      if (orderMap['id'] == null && orderMap['orderId'] == null) {
        orderMap['id'] = orderId;
      }

      return AdminOrderModel.fromJson(Map<String, dynamic>.from(orderMap))
          .toEntity();
    }
    throw Exception('Unexpected update order response');
  }

  @override
  Future<AdminOrder> incrementOrderStatus(String orderId) async {
    try {
      final resp = await apiService.post('/tracking/$orderId');

      if (resp.statusCode == 400) {
        throw Exception('The order has already been delivered');
      }
      if (resp.statusCode == 404) {
        throw Exception('No tracking history found for order with ID $orderId');
      }

      if (resp.data is Map) {
        final map = Map<String, dynamic>.from(resp.data as Map);
        final orderMap = map['order'] ?? map['data'] ?? map;

        if (orderMap['id'] == null && orderMap['orderId'] == null) {
          orderMap['id'] = orderId;
        }

        return AdminOrderModel.fromJson(Map<String, dynamic>.from(orderMap))
            .toEntity();
      }
      throw Exception('Unexpected increment status response');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('The order has already been delivered');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('No tracking history found for order with ID $orderId');
      }
      rethrow;
    }
  }
}
