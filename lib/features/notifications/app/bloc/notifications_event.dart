import 'package:amerli_app/features/notifications/domain/entities/notification.dart';

abstract class NotificationsEvent {}

class NotificationsLoadEvent extends NotificationsEvent {
	final int page;
	final int pageSize;
	NotificationsLoadEvent({this.page = 1, this.pageSize = 50});
}

class NotificationsMarkAllReadEvent extends NotificationsEvent {}

class NotificationsToggleReadEvent extends NotificationsEvent {
	final AppNotification notification;
	NotificationsToggleReadEvent(this.notification);
}

class NotificationsDeleteEvent extends NotificationsEvent {
	final int id;
	NotificationsDeleteEvent(this.id);
}
