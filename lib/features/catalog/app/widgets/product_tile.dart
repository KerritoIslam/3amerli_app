import 'package:flutter/material.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(product.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('EGP ${product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Text('Stock: ${product.stock}'),
          ],
        ),
      ),
    );
  }
}
