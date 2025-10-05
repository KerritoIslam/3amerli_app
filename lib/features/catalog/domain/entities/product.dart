import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;

  const Product({required this.id, required this.name, required this.description, required this.price, required this.stock});

  @override
  List<Object?> get props => [id, name, description, price, stock];
}
