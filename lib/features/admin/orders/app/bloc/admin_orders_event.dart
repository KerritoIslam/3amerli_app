abstract class AdminOrdersEvent {}

class AdminOrdersLoadEvent extends AdminOrdersEvent {
  final String? query;
  final int page;
  final int limit;

  AdminOrdersLoadEvent({this.query, this.page = 1, this.limit = 20});
}

class AdminOrdersLoadDetailEvent extends AdminOrdersEvent {
  final String orderId;

  AdminOrdersLoadDetailEvent(this.orderId);
}

class AdminOrdersUpdateStatusEvent extends AdminOrdersEvent {
  final String orderId;
  final String newStatus;

  AdminOrdersUpdateStatusEvent(this.orderId, this.newStatus);
}

class AdminOrdersIncrementStatusEvent extends AdminOrdersEvent {
  final String orderId;

  AdminOrdersIncrementStatusEvent(this.orderId);
}
