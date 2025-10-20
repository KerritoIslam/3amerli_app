import '../../domain/entities/order.dart';

class OrderProductModel extends OrderProduct {
  OrderProductModel({required String productId, required String name, required int quantity, required double price})
      : super(productId: productId, name: name, quantity: quantity, price: price);

  factory OrderProductModel.fromJson(Map<String, dynamic> json) => OrderProductModel(
        productId: json['productId'] as String,
        name: json['name'] as String,
        quantity: (json['quantity'] as num).toInt(),
        price: (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'quantity': quantity,
        'price': price,
      };
}
