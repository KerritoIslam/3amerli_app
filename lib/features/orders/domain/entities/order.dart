import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final int id;
  final int userId;
  final double totalAmount;
  final String status; // consider enum
  final DateTime createdAt;

  const Order({required this.id, required this.userId, required this.totalAmount, required this.status, required this.createdAt});

  @override
  List<Object?> get props => [id, userId, totalAmount, status, createdAt];
}
