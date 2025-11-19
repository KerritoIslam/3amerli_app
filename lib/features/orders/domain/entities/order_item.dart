import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;

  const OrderItem({required this.id, required this.orderId, required this.productId, required this.quantity, required this.unitPrice});

  @override
  List<Object?> get props => [id, orderId, productId, quantity, unitPrice];
}
