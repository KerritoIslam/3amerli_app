import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import '../../domain/repositories/admin_orders_repository.dart';
import 'admin_orders_event.dart';
import 'admin_orders_state.dart';

class AdminOrdersBloc extends Bloc<AdminOrdersEvent, AdminOrdersState> {
  final AdminOrdersRepository repository;

  AdminOrdersBloc(this.repository) : super(AdminOrdersInitial()) {
    on<AdminOrdersLoadEvent>(_onLoad);
    on<AdminOrdersLoadDetailEvent>(_onLoadDetail);
    on<AdminOrdersUpdateStatusEvent>(_onUpdateStatus);
    on<AdminOrdersIncrementStatusEvent>(_onIncrementStatus);
  }

  Future<void> _onLoad(
      AdminOrdersLoadEvent event, Emitter<AdminOrdersState> emit) async {
    if (event.page > 1 && state is AdminOrdersLoaded) {
      final currentState = state as AdminOrdersLoaded;
      // Allow loading if not currently loading more, even if hasMore was false previously (retry)
      // But strictly, if hasMore is false, we shouldn't load.
      // The issue might be that hasMore is not set correctly or isLoadingMore is stuck.
      if (currentState.isLoadingMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final result = await repository.getAllOrders(
            query: event.query, page: event.page, limit: event.limit);

        emit(currentState.copyWith(
          orders: currentState.orders + result.orders,
          currentPage: event.page,
          hasMore: result.hasNextPage,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
      return;
    }

    emit(AdminOrdersLoading());
    try {
      final result = await repository.getAllOrders(
          query: event.query, page: event.page, limit: event.limit);
      emit(AdminOrdersLoaded(
        result.orders,
        query: event.query,
        hasMore: result.hasNextPage,
        currentPage: event.page,
      ));
    } catch (e) {
      emit(AdminOrdersError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(
      AdminOrdersLoadDetailEvent event, Emitter<AdminOrdersState> emit) async {
    emit(AdminOrderDetailLoading());
    try {
      final order = await repository.getOrderById(event.orderId);
      emit(AdminOrderDetailLoaded(order));
    } catch (e) {
      emit(AdminOrdersError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(AdminOrdersUpdateStatusEvent event,
      Emitter<AdminOrdersState> emit) async {
    try {
      await repository.updateOrderStatus(event.orderId, event.newStatus);
      emit(AdminOrdersOperationSuccess(AppLanguage.updateSuccess));
      // Reload order detail after update
      add(AdminOrdersLoadDetailEvent(event.orderId));
    } catch (e) {
      emit(AdminOrdersError(e.toString()));
    }
  }

  Future<void> _onIncrementStatus(AdminOrdersIncrementStatusEvent event,
      Emitter<AdminOrdersState> emit) async {
    // 1. Set loading state
    if (state is AdminOrdersLoaded) {
      emit((state as AdminOrdersLoaded).copyWith(isIncrementing: true));
    } else if (state is AdminOrderDetailLoaded) {
      emit((state as AdminOrderDetailLoaded).copyWith(isIncrementing: true));
    }

    try {
      await repository.incrementOrderStatus(event.orderId);

      // Fetch fresh order details to ensure we have the latest data
      final updatedOrder = await repository.getOrderById(event.orderId);

      if (state is AdminOrdersLoaded) {
        final currentState = state as AdminOrdersLoaded;
        final updatedList = currentState.orders.map((o) {
          if (o.id == event.orderId) {
            return updatedOrder;
          }
          return o;
        }).toList();

        emit(currentState.copyWith(
            orders: updatedList,
            message: AppLanguage.updateSuccess,
            isIncrementing: false));
      } else if (state is AdminOrderDetailLoaded) {
        emit(AdminOrderDetailLoaded(updatedOrder,
            message: AppLanguage.updateSuccess, isIncrementing: false));
      } else {
        emit(AdminOrdersOperationSuccess(AppLanguage.updateSuccess));
      }
    } catch (e) {
      String message = e.toString();
      if (message.contains('Exception:')) {
        message = message.replaceAll('Exception:', '').trim();
      }

      // 2. Handle error state without reloading
      if (state is AdminOrdersLoaded) {
        emit((state as AdminOrdersLoaded)
            .copyWith(isIncrementing: false, errorMessage: message));
      } else if (state is AdminOrderDetailLoaded) {
        emit((state as AdminOrderDetailLoaded)
            .copyWith(isIncrementing: false, errorMessage: message));
      } else {
        emit(AdminOrdersError(message));
      }
    }
  }
}
