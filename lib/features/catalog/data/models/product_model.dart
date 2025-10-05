import 'package:amerli_app/features/catalog/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({required super.id, required super.name, required super.description, required super.price, required super.stock});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      stock: (json['stock'] is int) ? json['stock'] as int : int.tryParse(json['stock'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
    };
  }
}
