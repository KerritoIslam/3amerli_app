abstract class OrdersEvent {}

class OrdersLoadEvent extends OrdersEvent {
  final int page;
  final String? query;
  final String? status;
  OrdersLoadEvent({this.page = 1, this.query, this.status});
}

class OrdersCreateEvent extends OrdersEvent {
  final Map<String, dynamic> payload;
  OrdersCreateEvent({required this.payload});
}
