import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_orders_repository.dart';
import 'admin_orders_event.dart';
import 'admin_orders_state.dart';

class AdminOrdersBloc extends Bloc<AdminOrdersEvent, AdminOrdersState> {
  final AdminOrdersRepository repository;

  AdminOrdersBloc(this.repository) : super(AdminOrdersInitial()) {
    on<AdminOrdersLoadEvent>(_onLoad);
    on<AdminOrdersLoadDetailEvent>(_onLoadDetail);
    on<AdminOrdersUpdateStatusEvent>(_onUpdateStatus);
  }

  Future<void> _onLoad(AdminOrdersLoadEvent event, Emitter<AdminOrdersState> emit) async {
    emit(AdminOrdersLoading());
    try {
      final orders = await repository.getAllOrders(query: event.query);
      emit(AdminOrdersLoaded(orders, query: event.query));
    } catch (e) {
      emit(AdminOrdersError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(AdminOrdersLoadDetailEvent event, Emitter<AdminOrdersState> emit) async {
    emit(AdminOrderDetailLoading());
    try {
      final order = await repository.getOrderById(event.orderId);
      emit(AdminOrderDetailLoaded(order));
    } catch (e) {
      emit(AdminOrdersError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(AdminOrdersUpdateStatusEvent event, Emitter<AdminOrdersState> emit) async {
    try {
      await repository.updateOrderStatus(event.orderId, event.newStatus);
      emit(AdminOrdersOperationSuccess('Statut mis à jour avec succès'));
      // Reload order detail after update
      add(AdminOrdersLoadDetailEvent(event.orderId));
    } catch (e) {
      emit(AdminOrdersError(e.toString()));
    }
  }
}
