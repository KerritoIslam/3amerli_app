import 'package:amerli_app/features/orders/domain/entities/order.dart';
import 'package:amerli_app/features/orders/domain/entities/create_order_result.dart';
import 'package:amerli_app/features/orders/data/models/create_order_result.dart'
    as model;
import 'package:amerli_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:amerli_app/features/orders/data/datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrdersResult> fetchOrders({int page = 1, int limit = 20}) async {
    final result =
        await remoteDataSource.fetchOrders(page: page, pageSize: limit);
    final models = result['items'] as List;
    final meta = result['meta'] as Map<String, dynamic>?;

    final hasNext = meta?['hasNextPage'] ?? false;
    final total = (meta?['total'] as num?)?.toInt() ?? 0;

    return OrdersResult(
      orders: models.map((m) => m.toEntity()).toList().cast<Order>(),
      hasNextPage: hasNext,
      total: total,
    );
  }

  @override
  Future<CreateOrderResult> createOrder(Map<String, dynamic> payload) async {
    final model.CreateOrderResult result =
        await remoteDataSource.createOrder(payload);
    return result.toEntity();
  }
}
