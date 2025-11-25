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
    // API returns full URLs, no need to resolve them
    final pictureUrl = json['pictureUrl'] as String? ??
        json['imageUrl'] as String? ??
        json['picture'] as String?;

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['label'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: pictureUrl,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
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
  final String? imageUrl;
  final String categoryId;
  final String categoryName;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentImageUrl;

  SubCategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
    this.parentImageUrl,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    // API returns full URLs, no need to resolve them
    final pictureUrl = json['pictureUrl'] as String? ??
        json['imageUrl'] as String? ??
        json['picture'] as String?;

    return SubCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['label'] as String? ?? json['name'] as String? ?? '',
      imageUrl: pictureUrl,
      categoryId: json['parentCategory'] is Map
          ? (json['parentCategory']['id']?.toString() ?? '')
          : (json['categoryId']?.toString() ??
              json['parentId']?.toString() ??
              ''),
      categoryName: json['parentCategory'] is Map
          ? (json['parentCategory']['label'] as String? ??
              json['parentCategory']['name'] as String? ??
              '')
          : (json['categoryName'] as String? ??
              json['parentLabel'] as String? ??
              ''),
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      parentImageUrl: json['parentCategory'] is Map
          ? (json['parentCategory']['pictureUrl'] as String? ??
              json['parentCategory']['imageUrl'] as String?)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'parentImageUrl': parentImageUrl,
    };
  }

  SubCategory toEntity() {
    return SubCategory(
      id: id,
      name: name,
      imageUrl: imageUrl,
      categoryId: categoryId,
      categoryName: categoryName,
      productCount: productCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      parentImageUrl: parentImageUrl,
    );
  }

  factory SubCategoryModel.fromEntity(SubCategory subCategory) {
    return SubCategoryModel(
      id: subCategory.id,
      name: subCategory.name,
      imageUrl: subCategory.imageUrl,
      categoryId: subCategory.categoryId,
      categoryName: subCategory.categoryName,
      productCount: subCategory.productCount,
      createdAt: subCategory.createdAt,
      updatedAt: subCategory.updatedAt,
      parentImageUrl: subCategory.parentImageUrl,
    );
  }
}
