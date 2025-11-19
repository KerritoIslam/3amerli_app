import 'dart:async';

class MockOrdersRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      {
        'id': 'ord_1001',
        'sellerId': 'seller_1',
        'buyerId': 'buyer_1',
        'address': '12 Rue Abc, Alger',
        'paymentMethod': 'CASH',
        'status': 'CONFIRMED',
        'createdAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        'products': [
          {'productId': 'p1', 'name': 'Lait 1L', 'quantity': 2, 'price': 150.0},
          {'productId': 'p2', 'name': 'Pain', 'quantity': 1, 'price': 40.0},
        ]
      },
      {
        'id': 'ord_1002',
        'sellerId': 'seller_2',
        'buyerId': 'buyer_1',
        'address': '45 Avenue X, Oran',
        'paymentMethod': 'CARD',
        'status': 'PREPARING',
        'createdAt': DateTime.now().subtract(const Duration(hours: 1, minutes: 10)).toIso8601String(),
        'products': [
          {'productId': 'p3', 'name': 'Eau 500ml', 'quantity': 6, 'price': 30.0},
        ]
      },
      {
        'id': 'ord_1003',
        'sellerId': 'seller_3',
        'buyerId': 'buyer_2',
        'address': '9 Rue Y, Constantine',
        'paymentMethod': 'CASH',
        'status': 'DELIVERING',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'products': [
          {'productId': 'p4', 'name': 'Fromage', 'quantity': 1, 'price': 350.0},
          {'productId': 'p5', 'name': 'Tomates', 'quantity': 3, 'price': 60.0},
        ]
      },
      {
        'id': 'ord_1004',
        'sellerId': 'seller_1',
        'buyerId': 'buyer_3',
        'address': '1 Place Z, Annaba',
        'paymentMethod': 'CARD',
        'status': 'DELIVERED',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'products': [
          {'productId': 'p6', 'name': 'Café', 'quantity': 1, 'price': 800.0},
        ]
      }
    ];
  }
}
