import '../entities/order.dart';

abstract class OrdersRepository {
  Future<List<Order>> fetchOrders();

  // optional future methods
  Future<Order> createOrder(Map<String, dynamic> payload) async => throw UnimplementedError();
}
