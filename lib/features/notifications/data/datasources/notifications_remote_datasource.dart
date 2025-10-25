import 'package:amerli_app/core/dio/api_service.dart';
import '../models/notification_model.dart';

class NotificationsRemoteDataSource {
  final ApiService apiService;

  NotificationsRemoteDataSource({required this.apiService});

  Future<List<NotificationModel>> fetchNotifications({int page = 1, int pageSize = 50}) async {
    // Always return mocked sample data in development mode as requested.
    // This avoids making network calls and keeps the UI deterministic.
    // Debug: indicate mocked data is being returned
    // ignore: avoid_print
    print('NotificationsRemoteDataSource: returning mocked data (no API call)');
    await Future.delayed(const Duration(milliseconds: 400));
    final sample = [
      {
        'id': 1,
        'userId': 1,
        'title': 'Votre commande #A12345 est en cours de préparation.',
        'body': 'Nous préparons votre commande et elle sera expédiée bientôt.',
        'read': false,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      },
      {
        'id': 2,
        'userId': 1,
        'title': 'Votre commande #A12344 a été livrée.',
        'body': 'Merci pour votre achat. Votre commande a été livrée.',
        'read': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toUtc().toIso8601String(),
      },
      {
        'id': 3,
        'userId': 1,
        'title': 'Votre commande #A12340 est en attente.',
        'body': 'Nous avons un léger retard sur la préparation.',
        'read': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 3)).toUtc().toIso8601String(),
      },
      {
        'id': 4,
        'userId': 1,
        'title': 'Votre commande #A12339 a été annulée.',
        'body': 'La commande a été annulée suite à un problème de stock.',
        'read': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 6)).toUtc().toIso8601String(),
      }
    ];

    return sample.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markRead(int id) async {
    // Mock mark-read locally for development
    // ignore: avoid_print
    print('NotificationsRemoteDataSource: mock markRead for id=$id');
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
