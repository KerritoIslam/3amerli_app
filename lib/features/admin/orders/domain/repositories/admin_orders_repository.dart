import '../entities/admin_order.dart';

abstract class AdminOrdersRepository {
  Future<List<AdminOrder>> getAllOrders(
      {String? query, int page = 1, int limit = 20});
  Future<AdminOrder> getOrderById(String orderId);
  Future<AdminOrder> updateOrderStatus(String orderId, String newStatus);
  Future<AdminOrder> incrementOrderStatus(String orderId);
}
