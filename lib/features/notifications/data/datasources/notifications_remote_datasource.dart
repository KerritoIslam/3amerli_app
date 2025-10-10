import 'package:amerli_app/core/dio/api_service.dart';
import '../models/notification_model.dart';

class NotificationsRemoteDataSource {
  final ApiService apiService;

  NotificationsRemoteDataSource({required this.apiService});

  Future<List<NotificationModel>> fetchNotifications({int page = 1, int pageSize = 50}) async {
    final response = await apiService.get('/notifications', queryParameters: {'page': page, 'pageSize': pageSize});
    final List<dynamic> list = response.data as List<dynamic>;
    return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markRead(int id) async {
    await apiService.put('/notifications/$id/read');
  }
}
