import 'order_status.dart';
export 'order_status.dart';

class OrderProduct {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  OrderProduct({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class Order {
  final String id;
  final String sellerId;
  final String buyerId;
  final String address;
  final String paymentMethod;
  final List<OrderProduct> products;
  final OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.address,
    required this.paymentMethod,
    required this.products,
    required this.status,
    required this.createdAt,
  });
}
