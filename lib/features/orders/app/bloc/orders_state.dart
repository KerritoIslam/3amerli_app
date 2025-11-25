import 'package:amerli_app/features/orders/domain/entities/order.dart';

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<Order> items;
  OrdersLoaded(this.items);
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}

class OrderCreationError extends OrdersState {
  final String message;
  OrderCreationError(this.message);
}

class OrderCreated extends OrdersState {
  final Order order;
  final String? checkoutUrl;
  OrderCreated(this.order, {this.checkoutUrl});
}
