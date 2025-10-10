import '../../domain/entities/order_item.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;

  OrderItemModel({required this.id, required this.orderId, required this.productId, required this.quantity, required this.unitPrice});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        orderId: (json['orderId'] is num) ? (json['orderId'] as num).toInt() : int.tryParse(json['orderId']?.toString() ?? '') ?? 0,
        productId: (json['productId'] is num) ? (json['productId'] as num).toInt() : int.tryParse(json['productId']?.toString() ?? '') ?? 0,
        quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
        unitPrice: (json['unitPrice'] is num) ? (json['unitPrice'] as num).toDouble() : double.tryParse(json['unitPrice']?.toString() ?? '') ?? 0.0,
      );

  Map<String, dynamic> toJson() => {'id': id, 'orderId': orderId, 'productId': productId, 'quantity': quantity, 'unitPrice': unitPrice};

  OrderItem toEntity() => OrderItem(id: id, orderId: orderId, productId: productId, quantity: quantity, unitPrice: unitPrice);
}
