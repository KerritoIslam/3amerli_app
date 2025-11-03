import '../../domain/entities/admin_order.dart';

class OrderProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final int quantity;
  final double pricePerUnit;
  final double total;

  OrderProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.pricePerUnit,
    required this.total,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'] ?? 0,
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  OrderProduct toEntity() {
    return OrderProduct(
      id: id,
      name: name,
      imageUrl: imageUrl,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      total: total,
    );
  }
}

class AdminOrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String storeName;
  final String representativeName;
  final String customerPhone;
  final String orderDate;
  final String status;
  final double totalAmount;
  final int itemsCount;
  final String? deliveryAddress;
  final String paymentMethod;
  final List<OrderProductModel> products;

  AdminOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.storeName,
    required this.representativeName,
    required this.customerPhone,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.itemsCount,
    this.deliveryAddress,
    required this.paymentMethod,
    required this.products,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderModel(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      storeName: json['storeName'] ?? '',
      representativeName: json['representativeName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      orderDate: json['orderDate'] ?? '',
      status: json['status'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      itemsCount: json['itemsCount'] ?? 0,
      deliveryAddress: json['deliveryAddress'],
      paymentMethod: json['paymentMethod'] ?? '',
      products: (json['products'] as List?)
              ?.map((p) => OrderProductModel.fromJson(p))
              .toList() ??
          [],
    );
  }

  AdminOrder toEntity() {
    return AdminOrder(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      storeName: storeName,
      representativeName: representativeName,
      customerPhone: customerPhone,
      orderDate: DateTime.parse(orderDate),
      status: status,
      totalAmount: totalAmount,
      itemsCount: itemsCount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      products: products.map((p) => p.toEntity()).toList(),
    );
  }
}
