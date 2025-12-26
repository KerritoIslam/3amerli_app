import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';

class OrdersState {
  final bool loading;
  final List<Order> orders;
  final String? error;

  OrdersState({this.loading = false, this.orders = const [], this.error});

  OrdersState copyWith({bool? loading, List<Order>? orders, String? error}) =>
      OrdersState(
        loading: loading ?? this.loading,
        orders: orders ?? this.orders,
        error: error,
      );
}

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repository;

  OrdersCubit({required this.repository}) : super(OrdersState());

  Future<void> loadOrders() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final result = await repository.fetchOrders();
      emit(state.copyWith(loading: false, orders: result.orders));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
