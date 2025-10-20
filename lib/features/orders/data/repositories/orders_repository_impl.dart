import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/mock_orders_remote_datasource.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final MockOrdersRemoteDataSource remote;

  OrdersRepositoryImpl({required this.remote});

  @override
  Future<List<Order>> fetchOrders() async {
    final raw = await remote.fetchOrders();
    final models = raw.map((e) => OrderModel.fromJson(e)).toList();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Order> createOrder(Map<String, dynamic> payload) async {
    // Not implemented for the mock repository
    throw UnimplementedError();
  }
}
