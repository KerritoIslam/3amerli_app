import 'package:flutter/material.dart';

class OrdersPlaceholderPage extends StatelessWidget {
  const OrdersPlaceholderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commande')),
      body: const Center(child: Text('Détails de la commande (placeholder)')),
    );
  }
}
