import 'package:amerli_app/features/orders/domain/entities/order.dart';
import 'package:amerli_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:amerli_app/features/orders/data/datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Order>> getOrders({int page = 1, int pageSize = 50, String? query}) async {
    final models = await remoteDataSource.fetchOrders(page: page, pageSize: pageSize, query: query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Order> createOrder(Map<String, dynamic> payload) async {
    final model = await remoteDataSource.createOrder(payload);
    return model.toEntity();
  }
}
