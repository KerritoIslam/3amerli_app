import '../../domain/entities/admin_order.dart';
import '../../domain/repositories/admin_orders_repository.dart';
import '../models/admin_order_model.dart';

class AdminOrdersRepositoryImpl implements AdminOrdersRepository {
  // Mock data storage
  final List<AdminOrderModel> _mockOrders = [
    AdminOrderModel(
      id: 'MLG4537',
      orderNumber: 'MLG4537',
      customerName: 'Supérette El Baraka',
      storeName: 'Supérette El Baraka',
      representativeName: 'Nacer Amira Yassamine',
      customerPhone: '0665180239',
      orderDate: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      status: 'En attente',
      totalAmount: 316000.00,
      itemsCount: 4,
      deliveryAddress: '12 Rue des Jasmine, Quartier El Mokrani, Ain Naadja, Alger, Algérie',
      paymentMethod: 'Espèces à la livraison',
      products: [
        OrderProductModel(
          id: '1',
          name: 'Spaghetti Amor',
          imageUrl: 'https://via.placeholder.com/60',
          quantity: 5,
          pricePerUnit: 22000.00,
          total: 110000.00,
        ),
        OrderProductModel(
          id: '2',
          name: 'Sucre Mor',
          imageUrl: 'https://via.placeholder.com/60',
          quantity: 7,
          pricePerUnit: 9600.00,
          total: 67200.00,
        ),
        OrderProductModel(
          id: '3',
          name: 'Sucre Mor',
          imageUrl: 'https://via.placeholder.com/60',
          quantity: 3,
          pricePerUnit: 16200.00,
          total: 48600.00,
        ),
        OrderProductModel(
          id: '4',
          name: 'Sucre Mor',
          imageUrl: 'https://via.placeholder.com/60',
          quantity: 4,
          pricePerUnit: 22550.00,
          total: 90200.00,
        ),
      ],
    ),
    AdminOrderModel(
      id: 'MLG4538',
      orderNumber: 'MLG4538',
      customerName: 'Supérette El Baraka',
      storeName: 'Supérette El Baraka',
      representativeName: 'Ahmed Benali',
      customerPhone: '0555123456',
      orderDate: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      status: 'En attente',
      totalAmount: 250000.00,
      itemsCount: 3,
      deliveryAddress: '23 Rue de la Liberté, Alger',
      paymentMethod: 'Espèces à la livraison',
      products: [
        OrderProductModel(
          id: '1',
          name: 'Huile',
          imageUrl: 'https://via.placeholder.com/60',
          quantity: 10,
          pricePerUnit: 15000.00,
          total: 150000.00,
        ),
        OrderProductModel(
          id: '2',
          name: 'Riz',
          imageUrl: 'https://via.placeholder.com/60',
          quantity: 5,
          pricePerUnit: 20000.00,
          total: 100000.00,
        ),
      ],
    ),
    AdminOrderModel(
      id: 'MLG4539',
      orderNumber: 'MLG4539',
      customerName: 'Supérette El Baraka',
      storeName: 'Supérette El Baraka',
      representativeName: 'Fatima Meziane',
      customerPhone: '0555234567',
      orderDate: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      status: 'En cours',
      totalAmount: 180000.00,
      itemsCount: 2,
      deliveryAddress: '15 Avenue Mohamed V, Oran',
      paymentMethod: 'Montant',
      products: [
        OrderProductModel(
          id: '1',
          name: 'Café',
          imageUrl: 'https://via.placeholder.com/60',
          quantity: 12,
          pricePerUnit: 15000.00,
          total: 180000.00,
        ),
      ],
    ),
    AdminOrderModel(
      id: 'MLG4540',
      orderNumber: 'MLG4540',
      customerName: 'Supérette El Baraka',
      storeName: 'Supérette El Baraka',
      representativeName: 'Karim Djebbar',
      customerPhone: '0555345678',
      orderDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      status: 'En Préparation',
      totalAmount: 420000.00,
      itemsCount: 5,
      deliveryAddress: '42 Boulevard de la République, Constantine',
      paymentMethod: 'Espèces à la livraison',
      products: [],
    ),
    AdminOrderModel(
      id: 'MLG4541',
      orderNumber: 'MLG4541',
      customerName: 'Supérette El Baraka',
      storeName: 'Supérette El Baraka',
      representativeName: 'Amina Hamdi',
      customerPhone: '0555456789',
      orderDate: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      status: 'En attente',
      totalAmount: 195000.00,
      itemsCount: 3,
      deliveryAddress: '8 Rue des Frères Bouadou, Annaba',
      paymentMethod: 'Montant',
      products: [],
    ),
  ];

  @override
  Future<List<AdminOrder>> getAllOrders({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    List<AdminOrderModel> filteredOrders = _mockOrders;

    if (query != null && query.isNotEmpty) {
      filteredOrders = _mockOrders.where((order) {
        return order.orderNumber.toLowerCase().contains(query.toLowerCase()) ||
            order.customerName.toLowerCase().contains(query.toLowerCase()) ||
            order.storeName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    return filteredOrders.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AdminOrder> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final orderModel = _mockOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => _mockOrders.first,
    );

    return orderModel.toEntity();
  }

  @override
  Future<AdminOrder> updateOrderStatus(String orderId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _mockOrders[index] = AdminOrderModel(
        id: _mockOrders[index].id,
        orderNumber: _mockOrders[index].orderNumber,
        customerName: _mockOrders[index].customerName,
        storeName: _mockOrders[index].storeName,
        representativeName: _mockOrders[index].representativeName,
        customerPhone: _mockOrders[index].customerPhone,
        orderDate: _mockOrders[index].orderDate,
        status: newStatus,
        totalAmount: _mockOrders[index].totalAmount,
        itemsCount: _mockOrders[index].itemsCount,
        deliveryAddress: _mockOrders[index].deliveryAddress,
        paymentMethod: _mockOrders[index].paymentMethod,
        products: _mockOrders[index].products,
      );
      return _mockOrders[index].toEntity();
    }

    throw Exception('Order not found');
  }
}
