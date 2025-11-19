import '../../domain/entities/order.dart';

class OrderProductModel extends OrderProduct {
  OrderProductModel({required super.productId, required super.name, required super.quantity, required super.price});

  factory OrderProductModel.fromJson(Map<String, dynamic> json) => OrderProductModel(
        productId: json['productId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'quantity': quantity,
        'price': price,
      };
}
