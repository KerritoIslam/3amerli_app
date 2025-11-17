import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';

class OrderTile extends StatelessWidget {
  final Order order;

  const OrderTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final total = order.products.fold<double>(0.0, (prev, p) => prev + p.price * p.quantity);
    return Card(
      child: ListTile(
        title: Text('Commande ${order.id} - ${order.address}'),
        subtitle: Text('${order.products.length} articles · ${order.paymentMethod}'),
        trailing: Text('${total.toStringAsFixed(0)} DA'),
      ),
    );
  }
}
