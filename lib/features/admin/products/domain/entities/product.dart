class Product {
  final String id;
  final String name;
  final String category;
  final String brand;
  final int quantityPerLot;
  final List<String> specifications;
  final DateTime? expirationDate;
  final double pricePerLot;
  final String stockStatus; // 'En stock' or 'Rupture'
  final int availableQuantity;
  final List<String> images;
  final int mainImageIndex;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.quantityPerLot,
    required this.specifications,
    this.expirationDate,
    required this.pricePerLot,
    required this.stockStatus,
    required this.availableQuantity,
    required this.images,
    this.mainImageIndex = 0,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    int? quantityPerLot,
    List<String>? specifications,
    DateTime? expirationDate,
    double? pricePerLot,
    String? stockStatus,
    int? availableQuantity,
    List<String>? images,
    int? mainImageIndex,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      quantityPerLot: quantityPerLot ?? this.quantityPerLot,
      specifications: specifications ?? this.specifications,
      expirationDate: expirationDate ?? this.expirationDate,
      pricePerLot: pricePerLot ?? this.pricePerLot,
      stockStatus: stockStatus ?? this.stockStatus,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      images: images ?? this.images,
      mainImageIndex: mainImageIndex ?? this.mainImageIndex,
    );
  }
}
