import 'package:amerli_app/core/dio/api_service.dart';
import '../../domain/entities/admin_order.dart';
import '../../domain/repositories/admin_orders_repository.dart';
import '../models/admin_order_model.dart';

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
  Future<List<AdminOrder>> getAllOrders({String? query}) async {
    final qp = <String, dynamic>{};
    if (query != null && query.isNotEmpty) qp['search'] = query;
    final resp = await apiService.get('/order/admin/all', queryParameters: qp);
    final list = _extractList(resp.data);
    return list.map<AdminOrder>((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return AdminOrderModel.fromJson(map).toEntity();
    }).toList();
  }

  @override
  Future<AdminOrder> getOrderById(String orderId) async {
    final resp = await apiService.get('/order/$orderId/products');
    // the admin app expects a full AdminOrder; try GET /order/{id}/products may return items only
    if (resp.data is Map) {
      final map = Map<String, dynamic>.from(resp.data as Map);
      // If API returns the full order under data or order, adjust accordingly
      final orderMap = map['order'] ?? map['data'] ?? map;
      return AdminOrderModel.fromJson(Map<String, dynamic>.from(orderMap)).toEntity();
    }
    throw Exception('Unexpected order response');
  }

  @override
  Future<AdminOrder> updateOrderStatus(String orderId, String newStatus) async {
    final resp = await apiService.post('/order/$orderId/status', data: {'status': newStatus});
    if (resp.data is Map) {
      final map = Map<String, dynamic>.from(resp.data as Map);
      final orderMap = map['order'] ?? map['data'] ?? map;
      return AdminOrderModel.fromJson(Map<String, dynamic>.from(orderMap)).toEntity();
    }
    throw Exception('Unexpected update order response');
  }
}
