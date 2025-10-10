import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  const AppNotification({required this.id, required this.userId, required this.title, required this.body, required this.read, required this.createdAt});

  @override
  List<Object?> get props => [id, userId, title, body, read, createdAt];
}
