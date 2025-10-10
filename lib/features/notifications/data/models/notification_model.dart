import '../../domain/entities/notification.dart';

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final bool read;
  final String createdAt;

  NotificationModel({required this.id, required this.userId, required this.title, required this.body, required this.read, required this.createdAt});

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        userId: (json['userId'] is num) ? (json['userId'] as num).toInt() : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        read: json['read'] is bool ? (json['read'] as bool) : (json['read']?.toString() == 'true'),
        createdAt: json['createdAt']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'title': title, 'body': body, 'read': read, 'createdAt': createdAt};

  AppNotification toEntity() => AppNotification(id: id, userId: userId, title: title, body: body, read: read, createdAt: DateTime.tryParse(createdAt) ?? DateTime.now());
}
