import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;

  // Optional fields that may be present from other endpoints
  final int? sellerId;
  final String? pic;
  final String? markId;
  // Favorite flag for UI and domain logic
  final bool isFavorit;
  // Quantity of this product currently in the cart
  final int quantity;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.sellerId,
    this.pic,
    this.markId,
    this.isFavorit = false,
    this.quantity = 0,
  });

  @override
  List<Object?> get props => [id, name, description, price, stock, sellerId, pic, markId, isFavorit, quantity];
}
