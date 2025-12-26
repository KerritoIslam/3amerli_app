import '../entities/order.dart';
import '../entities/create_order_result.dart';
import '../entities/tracking_step.dart';

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
  Future<OrdersResult> fetchOrders(
      {int page = 1, int limit = 20, String? status});

  // optional future methods
  Future<CreateOrderResult> createOrder(Map<String, dynamic> payload) async =>
      throw UnimplementedError();

  Future<List<TrackingStep>> fetchTracking(String orderId) async =>
      throw UnimplementedError();
}
