import '../../domain/entities/order.dart';
import 'order_product_model.dart';

class OrderModel extends Order {
  OrderModel({
    required super.id,
    required super.sellerId,
    required super.buyerId,
    required super.address,
    required super.paymentMethod,
    required List<OrderProductModel> super.products,
    required super.status,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id']?.toString() ?? '',
        sellerId: json['sellerId']?.toString() ?? '',
        buyerId: json['buyerId']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        paymentMethod: json['paymentMethod']?.toString() ?? json['payementWay']?.toString() ?? '',
        products: (json['products'] as List<dynamic>?)?.map((e) => OrderProductModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
        status: OrderStatusX.fromString(json['status']?.toString() ?? 'pending'),
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
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

