class Product {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String brand;
  final String? categoryId;
  final String? brandId;
  final int quantityPerLot;
  final List<String> specifications;
  final DateTime? expirationDate;
  final double pricePerLot;
  final String stockStatus; // 'En stock' or 'Rupture'
  final int availableQuantity;
  final List<String> images;
  final int mainImageIndex;
  final List<int>? pictureIds;
  final List<int>? picturesToDelete;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.brand,
    this.categoryId,
    this.brandId,
    required this.quantityPerLot,
    required this.specifications,
    this.expirationDate,
    required this.pricePerLot,
    required this.stockStatus,
    required this.availableQuantity,
    required this.images,
    this.mainImageIndex = 0,
    this.pictureIds,
    this.picturesToDelete,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? brand,
    String? categoryId,
    String? brandId,
    int? quantityPerLot,
    List<String>? specifications,
    DateTime? expirationDate,
    double? pricePerLot,
    String? stockStatus,
    int? availableQuantity,
    List<String>? images,
    int? mainImageIndex,
    List<int>? pictureIds,
    List<int>? picturesToDelete,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      quantityPerLot: quantityPerLot ?? this.quantityPerLot,
      specifications: specifications ?? this.specifications,
      expirationDate: expirationDate ?? this.expirationDate,
      pricePerLot: pricePerLot ?? this.pricePerLot,
      stockStatus: stockStatus ?? this.stockStatus,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      images: images ?? this.images,
      mainImageIndex: mainImageIndex ?? this.mainImageIndex,
      pictureIds: pictureIds ?? this.pictureIds,
      picturesToDelete: picturesToDelete ?? this.picturesToDelete,
    );
  }
}
