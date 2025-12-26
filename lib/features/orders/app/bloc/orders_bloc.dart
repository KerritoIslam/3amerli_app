import 'package:amerli_app/features/orders/domain/entities/order.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_event.dart';
import 'orders_state.dart';
import 'package:amerli_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:amerli_app/core/network/api_exception.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository repository;

  OrdersBloc({required this.repository}) : super(OrdersInitial()) {
    on<OrdersLoadEvent>(_onLoad);
    on<OrdersCreateEvent>(_onCreate);
  }

  Future<void> _onLoad(OrdersLoadEvent event, Emitter<OrdersState> emit) async {
    final isFirstPage = event.page == 1;
    List<Order> currentOrders = [];

    if (state is OrdersLoaded && !isFirstPage) {
      currentOrders = (state as OrdersLoaded).items;
    } else {
      emit(OrdersLoading());
    }

    try {
      final result = await repository.fetchOrders(
        page: event.page,
        status: event.status,
      );

      final newOrders =
          isFirstPage ? result.orders : [...currentOrders, ...result.orders];

      emit(OrdersLoaded(
        newOrders,
        hasNextPage: result.hasNextPage,
        total: result.total,
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onCreate(
      OrdersCreateEvent event, Emitter<OrdersState> emit) async {
    try {
      final result = await repository.createOrder(event.payload);
      emit(OrderCreated(result.order, checkoutUrl: result.checkoutUrl));
      // Reload orders list
      add(OrdersLoadEvent());
    } catch (e) {
      // Extract clean error message from ApiException
      String errorMessage = e.toString();
      if (e is ApiException) {
        errorMessage = e.message;
      }
      // Use OrderCreationError to avoid showing in orders list page
      emit(OrderCreationError(errorMessage));
    }
  }
}
