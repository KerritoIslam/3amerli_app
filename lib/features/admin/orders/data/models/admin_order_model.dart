import '../../domain/entities/admin_order.dart';
import 'package:amerli_app/features/orders/domain/entities/order_status.dart';

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
    try {
      return OrderProductModel(
        id: (json['id'] ?? '').toString(),
        name: json['name'] ?? '',
        imageUrl: json['imageUrl'] ?? json['picture'] ?? '',
        quantity: (() {
          final q = json['quantity'] ?? json['qty'] ?? 0;
          if (q is int) return q;
          if (q is num) return q.toInt();
          if (q is String) return int.tryParse(q) ?? 0;
          return 0;
        })(),
        pricePerUnit: (() {
          final p = json['pricePerUnit'] ?? json['price'] ?? 0;
          if (p is num) return p.toDouble();
          if (p is String) return double.tryParse(p) ?? 0.0;
          return 0.0;
        })(),
        total: (() {
          final t = json['total'] ?? json['subtotal'];
          if (t != null) {
            if (t is num) return t.toDouble();
            if (t is String) return double.tryParse(t) ?? 0.0;
          }
          // Calculate from quantity * price if total is missing
          final q = json['quantity'] ?? json['qty'] ?? 0;
          final quantity =
              (q is int) ? q : (q is String ? int.tryParse(q) ?? 0 : 0);

          final p = json['pricePerUnit'] ?? json['price'] ?? 0;
          final price = (p is num)
              ? p.toDouble()
              : (p is String ? double.tryParse(p) ?? 0.0 : 0.0);

          return (quantity * price).toDouble();
        })(),
      );
    } catch (e) {
      print('Error parsing OrderProductModel: $e');
      rethrow;
    }
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
    try {
      final buyerInfo = json['buyerInfo'];
      final paymentInfo = json['paymentInfo'];

      final idRaw = json['id'] ?? json['orderId'] ?? json['order_id'];
      final id = idRaw != null ? idRaw.toString() : '';

      final orderDate = paymentInfo != null
          ? (paymentInfo['createdAt'] ?? paymentInfo['created_at'])
          : (json['orderDate'] ??
              json['order_date'] ??
              json['createdAt'] ??
              json['created_at'] ??
              '');

      final productsList =
          json['products'] ?? json['items'] ?? json['orderProducts'];

      return AdminOrderModel(
        id: id,
        // fallback: some APIs return clientName instead of customerName
        orderNumber: json['orderNumber'] ?? json['order_number'] ?? id,
        customerName: buyerInfo != null
            ? (buyerInfo['clientName'] ?? '')
            : (json['customerName'] ??
                json['customer_name'] ??
                json['clientName'] ??
                json['client_name'] ??
                ''),
        storeName: buyerInfo != null
            ? (buyerInfo['supermarketName'] ?? '')
            : (json['storeName'] ?? json['store_name'] ?? ''),
        representativeName:
            json['representativeName'] ?? json['representative_name'] ?? '',
        customerPhone: buyerInfo != null
            ? (buyerInfo['phoneNumber'] ?? '')
            : (json['customerPhone'] ?? json['customer_phone'] ?? ''),
        orderDate: orderDate ?? '',
        status: paymentInfo != null
            ? (paymentInfo['trackingStatus'] ?? '')
            : (json['status'] ?? ''),
        totalAmount: paymentInfo != null
            ? ((paymentInfo['totalAmount'] ?? 0).toDouble())
            : ((json['totalAmount'] ?? json['total'] ?? 0).toDouble()),
        itemsCount: json['itemsCount'] ??
            json['items_count'] ??
            (productsList is List ? productsList.length : 0),
        deliveryAddress: buyerInfo != null
            ? (buyerInfo['address'])
            : (json['deliveryAddress'] ?? json['delivery_address']),
        paymentMethod: paymentInfo != null
            ? (paymentInfo['paymentWay'] ?? '')
            : (json['paymentMethod'] ?? json['payment_method'] ?? ''),
        products: (productsList as List?)
                ?.map((p) => OrderProductModel.fromJson(
                    Map<String, dynamic>.from(p as Map)))
                .toList() ??
            [],
      );
    } catch (e) {
      print('Error parsing AdminOrderModel: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  AdminOrder toEntity() {
    return AdminOrder(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      storeName: storeName,
      representativeName: representativeName,
      customerPhone: customerPhone,
      // parse date defensively
      orderDate:
          _parseDateSafe(orderDate) ?? DateTime.fromMillisecondsSinceEpoch(0),
      // convert backend status string to a user-facing French label using OrderStatus mapping
      status: OrderStatusX.fromString(status).displayLabel,
      totalAmount: totalAmount,
      itemsCount: itemsCount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      products: products.map((p) => p.toEntity()).toList(),
    );
  }

  static DateTime? _parseDateSafe(String? raw) {
    if (raw == null) return null;
    if (raw.isEmpty) return null;
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;
    final asInt = int.tryParse(raw);
    if (asInt != null) {
      if (raw.length <= 10)
        return DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
      return DateTime.fromMillisecondsSinceEpoch(asInt);
    }
    return null;
  }
}
