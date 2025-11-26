import '../entities/order.dart';
import '../entities/create_order_result.dart';

class OrdersResult {
  final List<Order> orders;
  final bool hasNextPage;
  final int total;

  OrdersResult({
    required this.orders,
    this.hasNextPage = false,
    this.total = 0,
  });
}

abstract class OrdersRepository {
  Future<OrdersResult> fetchOrders({int page = 1, int limit = 20});

  // optional future methods
  Future<CreateOrderResult> createOrder(Map<String, dynamic> payload) async =>
      throw UnimplementedError();
}
