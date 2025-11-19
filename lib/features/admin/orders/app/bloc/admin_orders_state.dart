import '../../domain/entities/admin_order.dart';

abstract class AdminOrdersState {}

class AdminOrdersInitial extends AdminOrdersState {}

class AdminOrdersLoading extends AdminOrdersState {}

class AdminOrdersLoaded extends AdminOrdersState {
  final List<AdminOrder> orders;
  final String? query;

  AdminOrdersLoaded(this.orders, {this.query});
}

class AdminOrderDetailLoading extends AdminOrdersState {}

class AdminOrderDetailLoaded extends AdminOrdersState {
  final AdminOrder order;

  AdminOrderDetailLoaded(this.order);
}

class AdminOrdersError extends AdminOrdersState {
  final String message;

  AdminOrdersError(this.message);
}

class AdminOrdersOperationSuccess extends AdminOrdersState {
  final String message;

  AdminOrdersOperationSuccess(this.message);
}
