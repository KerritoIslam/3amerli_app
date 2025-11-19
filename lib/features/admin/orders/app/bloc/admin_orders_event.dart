abstract class AdminOrdersEvent {}

class AdminOrdersLoadEvent extends AdminOrdersEvent {
  final String? query;

  AdminOrdersLoadEvent({this.query});
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
