import '../../domain/entities/category.dart';
import 'product_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final List<ProductModel> products;
  final List<CategoryModel> subcategories;
  
  CategoryModel({required this.id, required this.name, this.description, this.image, this.products = const [], this.subcategories = const []});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        image: json['image']?.toString(),
        products: (json['products'] is List) ? (json['products'] as List<dynamic>).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList() : [],
        subcategories: (json['subcategories'] is List)
            ? (json['subcategories'] as List<dynamic>)
                .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description, 'image': image, 'products': products.map((p) => p.toJson()).toList()};
  Map<String, dynamic> toJsonFull() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'products': products.map((p) => p.toJson()).toList(),
        'subcategories': subcategories.map((c) => c.toJsonFull()).toList(),
      };

  Category toEntity() => Category(
        id: id,
        name: name,
        description: description,
        image: image,
        products: products.map((p) => p.toEntity()).toList(),
        subcategories: subcategories.map((c) => c.toEntity()).toList(),
      );
}
