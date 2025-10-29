import '../../domain/entities/order.dart';

class OrderProductModel extends OrderProduct {
  OrderProductModel({required String productId, required String name, required int quantity, required double price})
      : super(productId: productId, name: name, quantity: quantity, price: price);

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
