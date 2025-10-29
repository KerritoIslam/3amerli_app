import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_event.dart';
import 'orders_state.dart';
import 'package:amerli_app/features/orders/domain/repositories/orders_repository.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository repository;

  OrdersBloc({required this.repository}) : super(OrdersInitial()) {
    on<OrdersLoadEvent>(_onLoad);
    on<OrdersCreateEvent>(_onCreate);
  }

  Future<void> _onLoad(OrdersLoadEvent event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
  final items = await repository.fetchOrders();
      emit(OrdersLoaded(items));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onCreate(OrdersCreateEvent event, Emitter<OrdersState> emit) async {
    try {
      final result = await repository.createOrder(event.payload);
      emit(OrderCreated(result.order, checkoutUrl: result.checkoutUrl));
      // Reload orders list
      add(OrdersLoadEvent());
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}

