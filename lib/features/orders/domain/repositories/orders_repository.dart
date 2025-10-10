import 'package:amerli_app/features/orders/domain/entities/order.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrders({int page = 1, int pageSize = 50, String? query});
  Future<Order> createOrder(Map<String, dynamic> payload);
}
