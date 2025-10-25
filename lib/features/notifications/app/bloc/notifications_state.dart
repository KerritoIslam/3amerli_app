import 'package:amerli_app/features/notifications/domain/entities/notification.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
	final List<AppNotification> items;
	NotificationsLoaded(this.items);
}

class NotificationsError extends NotificationsState {
	final String message;
	NotificationsError(this.message);
}
