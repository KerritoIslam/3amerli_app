import '../../domain/entities/product.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;

  ProductModel({required this.id, required this.name, required this.description, required this.price, required this.stock});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Be defensive: ids may be strings in some APIs
    final rawId = json['id'];
    final id = rawId is String ? int.tryParse(rawId) ?? 0 : (rawId as num).toInt();

    return ProductModel(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      stock: (json['stock'] is num) ? (json['stock'] as num).toInt() : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
      };

  Product toEntity() => Product(id: id, name: name, description: description, price: price, stock: stock);
}
