import '../entities/admin_order.dart';

class AdminOrdersResult {
  final List<AdminOrder> orders;
  final bool hasNextPage;
  final int total;

  AdminOrdersResult({
    required this.orders,
    this.hasNextPage = false,
    this.total = 0,
  });
}

abstract class AdminOrdersRepository {
  Future<AdminOrdersResult> getAllOrders(
      {String? query, int page = 1, int limit = 20});
  Future<AdminOrder> getOrderById(String orderId);
  Future<AdminOrder> updateOrderStatus(String orderId, String newStatus);
  Future<AdminOrder> incrementOrderStatus(String orderId);
}
