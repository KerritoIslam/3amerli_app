import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.brand,
    required super.quantityPerLot,
    required super.specifications,
    super.expirationDate,
    required super.pricePerLot,
    required super.stockStatus,
    required super.availableQuantity,
    required super.images,
    super.mainImageIndex,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      quantityPerLot: json['quantity_per_lot'] as int,
      specifications: (json['specifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      pricePerLot: (json['price_per_lot'] as num).toDouble(),
      stockStatus: json['stock_status'] as String,
      availableQuantity: json['available_quantity'] as int,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mainImageIndex: json['main_image_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'brand': brand,
      'quantity_per_lot': quantityPerLot,
      'specifications': specifications,
      'expiration_date': expirationDate?.toIso8601String(),
      'price_per_lot': pricePerLot,
      'stock_status': stockStatus,
      'available_quantity': availableQuantity,
      'images': images,
      'main_image_index': mainImageIndex,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      category: product.category,
      brand: product.brand,
      quantityPerLot: product.quantityPerLot,
      specifications: product.specifications,
      expirationDate: product.expirationDate,
      pricePerLot: product.pricePerLot,
      stockStatus: product.stockStatus,
      availableQuantity: product.availableQuantity,
      images: product.images,
      mainImageIndex: product.mainImageIndex,
    );
  }
}
