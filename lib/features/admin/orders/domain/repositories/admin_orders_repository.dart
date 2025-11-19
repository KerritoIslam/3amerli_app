import '../entities/admin_order.dart';

abstract class AdminOrdersRepository {
  Future<List<AdminOrder>> getAllOrders({String? query});
  Future<AdminOrder> getOrderById(String orderId);
  Future<AdminOrder> updateOrderStatus(String orderId, String newStatus);
}
