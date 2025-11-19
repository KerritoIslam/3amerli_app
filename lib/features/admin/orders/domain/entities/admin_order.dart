class OrderProduct {
  final String id;
  final String name;
  final String imageUrl;
  final int quantity;
  final double pricePerUnit;
  final double total;

  OrderProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.pricePerUnit,
    required this.total,
  });
}

class AdminOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String storeName;
  final String representativeName;
  final String customerPhone;
  final DateTime orderDate;
  final String status;
  final double totalAmount;
  final int itemsCount;
  final String? deliveryAddress;
  final String paymentMethod;
  final List<OrderProduct> products;

  AdminOrder({
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
}
