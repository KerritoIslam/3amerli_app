import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:flutter/material.dart';

class ProductTile extends StatefulWidget {
  final Product product;
  final int quantity;
  final Function(int) onQuantityChange;
  const ProductTile({super.key, required this.product, required this.quantity, required this.onQuantityChange});

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.network(widget.product.pic ?? ''),
          Column(
            children: [
              Text(widget.product.name),
              Text(widget.product.description),
              Text('${widget.product.price.toStringAsFixed(2)} DZD'),
              Text('Vondu par 2'),//TODO: change to sold by atribute later
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: () {widget.onQuantityChange(widget.quantity - 1);}, icon: Icon(Icons.remove)),
              Text('${widget.quantity}'),
              IconButton(onPressed: () {widget.onQuantityChange(widget.quantity + 1);}, icon: Icon(Icons.add)),
            ],
          ),
        ],
      ),
    );
  }
}