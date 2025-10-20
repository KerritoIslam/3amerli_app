import 'package:flutter/material.dart';

class OrdersMainPage extends StatelessWidget {
  const OrdersMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.receipt_long, size: 64),
                SizedBox(height: 12),
                Text('Orders (placeholder)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('This page will list user orders grouped by status.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
