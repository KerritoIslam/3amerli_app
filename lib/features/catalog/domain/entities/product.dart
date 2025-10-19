import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;

  // Optional fields that may be present from other endpoints
  final int? sellerId;
  // Optional seller id from APIs under the key `soldBy`
  final int? soldBy;
  // List of image URLs for the product. The first element is the thumbnail
  // used across lists, the second can be used in the product details page.
  final List<String> pics;
  // Optional brand name for the product
  final String? brand;
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
    this.soldBy,
    this.pics = const [],
    this.brand,
    this.markId,
    this.isFavorit = false,
    this.quantity = 0,
  });

  @override
  List<Object?> get props => [id, name, description, price, stock, sellerId, soldBy, pics, brand, markId, isFavorit, quantity];
}
