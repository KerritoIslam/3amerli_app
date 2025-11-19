import '../../domain/entities/transaction.dart';

class TransactionModel {
  final int id;
  final int userId;
  final double amount;
  final String status;
  final String createdAt;
  final String? paymentUrl;

  TransactionModel({required this.id, required this.userId, required this.amount, required this.status, required this.createdAt, this.paymentUrl});

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    // Support both flat transaction objects and nested checkout responses
    // where the payload might be: { "order": { ... }, "checkoutUrl": "..." }
    // Normalize by selecting the inner map if present.
    id: (json['id'] is num)
      ? (json['id'] as num).toInt()
      : (json['order'] is Map && (json['order']['id'] is num))
        ? (json['order']['id'] as num).toInt()
        : int.tryParse(json['id']?.toString() ?? json['order']?['id']?.toString() ?? '') ?? 0,
    userId: (json['userId'] is num)
      ? (json['userId'] as num).toInt()
      : (json['order'] is Map && (json['order']['userId'] is num))
        ? (json['order']['userId'] as num).toInt()
        : int.tryParse(json['userId']?.toString() ?? json['order']?['userId']?.toString() ?? '') ?? 0,
    amount: (json['amount'] is num)
      ? (json['amount'] as num).toDouble()
      : (json['order'] is Map && (json['order']['totalAmount'] is num))
        ? (json['order']['totalAmount'] as num).toDouble()
        : double.tryParse(json['amount']?.toString() ?? json['order']?['totalAmount']?.toString() ?? '') ?? 0.0,
    status: json['status']?.toString() ?? json['order']?['status']?.toString() ?? '',
    createdAt: json['createdAt']?.toString() ?? json['order']?['createdAt']?.toString() ?? '',
    // checkout url may be at top-level 'checkoutUrl', or 'paymentUrl', or inside 'order'
    paymentUrl: (json['checkoutUrl']?.toString()) ?? json['paymentUrl']?.toString() ?? json['url']?.toString() ?? json['order']?['checkoutUrl']?.toString(),
    );

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'amount': amount, 'status': status, 'createdAt': createdAt, if (paymentUrl != null) 'paymentUrl': paymentUrl};

  TransactionEntity toEntity() => TransactionEntity(id: id, userId: userId, amount: amount, status: status, createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(), paymentUrl: paymentUrl);
}
