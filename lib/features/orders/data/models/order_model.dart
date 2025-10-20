import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import 'order_product_model.dart';

class OrderModel extends Order {
  OrderModel({
    required String id,
    required String sellerId,
    required String buyerId,
    required String address,
    required String paymentMethod,
    required List<OrderProductModel> products,
    required OrderStatus status,
    required DateTime createdAt,
  }) : super(
          id: id,
          sellerId: sellerId,
          buyerId: buyerId,
          address: address,
          paymentMethod: paymentMethod,
          products: products,
          status: status,
          createdAt: createdAt,
        );

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        sellerId: json['sellerId'] as String,
        buyerId: json['buyerId'] as String,
        address: json['address'] as String,
        paymentMethod: json['paymentMethod'] as String,
        products: (json['products'] as List<dynamic>).map((e) => OrderProductModel.fromJson(e as Map<String, dynamic>)).toList(),
        status: OrderStatusX.fromString(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sellerId': sellerId,
        'buyerId': buyerId,
        'address': address,
        'paymentMethod': paymentMethod,
        'products': products.map((p) => (p as OrderProductModel).toJson()).toList(),
        'status': status.nameValue,
        'createdAt': createdAt.toIso8601String(),
      };
  
  Order toEntity() => Order(
        id: id,
        sellerId: sellerId,
        buyerId: buyerId,
        address: address,
        paymentMethod: paymentMethod,
        products: products,
        status: status,
        createdAt: createdAt,
      );
}

