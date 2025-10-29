import 'package:amerli_app/features/orders/domain/entities/order.dart';
import 'package:amerli_app/features/orders/domain/entities/create_order_result.dart';
import 'package:amerli_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:amerli_app/features/orders/data/datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Order>> fetchOrders() async {
    final models = await remoteDataSource.fetchOrders();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CreateOrderResult> createOrder(Map<String, dynamic> payload) async {
    final result = await remoteDataSource.createOrder(payload);
    return result.toEntity();
  }
}
