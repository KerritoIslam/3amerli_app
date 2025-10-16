import 'package:amerli_app/features/cart/app/widgets/product_tile.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:flutter/material.dart';

class ProductsTilesList extends StatefulWidget {
  final List<Product> products;
  final Function(int, int) onQuantityChange;
  const ProductsTilesList({super.key, required this.products, required this.onQuantityChange});

  @override
  State<ProductsTilesList> createState() => _ProductsTilesListState();
}

class _ProductsTilesListState extends State<ProductsTilesList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.products.length,
      itemBuilder: (context, index) => ProductTile(product: widget.products[index], quantity: widget.products[index].quantity, onQuantityChange: (quantity) {
        widget.onQuantityChange(index, quantity);
      }),
    );
  }
}