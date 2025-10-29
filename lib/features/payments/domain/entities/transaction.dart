import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final int id;
  final int userId;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? paymentUrl;

  const TransactionEntity({required this.id, required this.userId, required this.amount, required this.status, required this.createdAt, this.paymentUrl});

  @override
  List<Object?> get props => [id, userId, amount, status, createdAt];
}
