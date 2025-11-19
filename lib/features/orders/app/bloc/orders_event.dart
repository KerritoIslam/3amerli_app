abstract class OrdersEvent {}

class OrdersLoadEvent extends OrdersEvent {
	final int page;
	final String? query;
	OrdersLoadEvent({this.page = 1, this.query});
}

class OrdersCreateEvent extends OrdersEvent {
	final Map<String, dynamic> payload;
	OrdersCreateEvent({required this.payload});
}
