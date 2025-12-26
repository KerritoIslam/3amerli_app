import 'order_status.dart';
export 'order_status.dart';

class OrderProduct {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;

  OrderProduct({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });
}

class Order {
  final String id;
  final String sellerId;
  final String buyerId;
  final String address;
  final String paymentMethod;
  final double totalAmount;
  final List<OrderProduct> products;
  final OrderStatus status;
  final DateTime createdAt;
  final int productCount;

  Order({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.address,
    required this.paymentMethod,
    required this.totalAmount,
    required this.products,
    required this.status,
    required this.createdAt,
    this.productCount = 0,
  });
}
