import '../entities/order.dart';
import '../entities/create_order_result.dart';

abstract class OrdersRepository {
  Future<List<Order>> fetchOrders();

  // optional future methods
  Future<CreateOrderResult> createOrder(Map<String, dynamic> payload) async => throw UnimplementedError();
}
