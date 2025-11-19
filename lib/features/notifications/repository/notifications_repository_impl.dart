import 'package:amerli_app/features/notifications/domain/entities/notification.dart';
import 'package:amerli_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:amerli_app/features/notifications/data/datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AppNotification>> getNotifications({int page = 1, int pageSize = 50}) async {
    final models = await remoteDataSource.fetchNotifications(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markRead(int id) async {
    await remoteDataSource.markRead(id);
  }

  @override
  Future<void> markMultipleRead(List<int> ids) async {
    await remoteDataSource.markMultipleRead(ids);
  }

  @override
  Future<void> deleteNotification(int id) async {
    await remoteDataSource.deleteNotification(id.toString());
  }

  @override
  Future<void> registerFcmToken(String token, String os) async {
    await remoteDataSource.registerFcmToken(token, os);
  }
}
