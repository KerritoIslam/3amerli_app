import 'package:amerli_app/features/notifications/domain/entities/notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications({int page = 1, int pageSize = 50});
  Future<void> markRead(int id);
  Future<void> markMultipleRead(List<int> ids);
  Future<void> deleteNotification(int id);
  Future<void> registerFcmToken(String token, String os);
}
