import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['pictureUrl'] as String? ?? json['imageUrl'] as String?,
      productCount: json['productCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      productCount: productCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      imageUrl: category.imageUrl,
      productCount: category.productCount,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}

class SubCategoryModel {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      productCount: json['productCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SubCategory toEntity() {
    return SubCategory(
      id: id,
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
      productCount: productCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory SubCategoryModel.fromEntity(SubCategory subCategory) {
    return SubCategoryModel(
      id: subCategory.id,
      name: subCategory.name,
      categoryId: subCategory.categoryId,
      categoryName: subCategory.categoryName,
      productCount: subCategory.productCount,
      createdAt: subCategory.createdAt,
      updatedAt: subCategory.updatedAt,
    );
  }
}
