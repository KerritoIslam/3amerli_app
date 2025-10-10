import '../../domain/entities/transaction.dart';

class TransactionModel {
  final int id;
  final int userId;
  final double amount;
  final String status;
  final String createdAt;

  TransactionModel({required this.id, required this.userId, required this.amount, required this.status, required this.createdAt});

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        userId: (json['userId'] is num) ? (json['userId'] as num).toInt() : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
        amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
        status: json['status']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'amount': amount, 'status': status, 'createdAt': createdAt};

  TransactionEntity toEntity() => TransactionEntity(id: id, userId: userId, amount: amount, status: status, createdAt: DateTime.tryParse(createdAt) ?? DateTime.now());
}
