class Category {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
  });

  final String? parentId;
}

class SubCategory {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });
}
