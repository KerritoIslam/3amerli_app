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

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.sellerId,
    this.pic,
    this.markId,
  });

  @override
  List<Object?> get props => [id, name, description, price, stock, sellerId, pic, markId];
}
