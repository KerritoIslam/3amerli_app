import 'package:equatable/equatable.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final List<Product> products;

  const Category({required this.id, required this.name, this.description, this.image, this.products = const []});

  @override
  List<Object?> get props => [id, name, description, image, products];
}
