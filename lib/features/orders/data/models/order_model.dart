import '../../domain/entities/order.dart';
import 'order_item_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final double totalAmount;
  final String status;
  final String createdAt; // keep raw for now
  final List<OrderItemModel> items;

  OrderModel({required this.id, required this.userId, required this.totalAmount, required this.status, required this.createdAt, required this.items});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: (json['userId'] is num) ? (json['userId'] as num).toInt() : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : double.tryParse(json['totalAmount']?.toString() ?? '') ?? 0.0,
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      items: itemsJson.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'totalAmount': totalAmount,
        'status': status,
        'createdAt': createdAt,
        'items': items.map((i) => i.toJson()).toList(),
      };

  Order toEntity() => Order(id: id, userId: userId, totalAmount: totalAmount, status: status, createdAt: DateTime.tryParse(createdAt) ?? DateTime.now());
}
