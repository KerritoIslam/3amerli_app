import '../../domain/entities/product.dart';
import '../../../../../utils/image_resolver.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.brand,
    super.categoryId,
    super.brandId,
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
    // Accept multiple possible key names and types from backend
    String id = '';
    final rawId = json['id'] ?? json['productId'] ?? json['product_id'];
    if (rawId != null) id = rawId.toString();

    String name = (json['name'] ?? json['label'] ?? '') as String;

    // category may be a name or an object/id
    String category = '';
    if (json['category'] is String) {
      category = json['category'] as String;
    } else if (json['category'] is Map) {
      category = (json['category']['label'] ?? json['category']['name'] ?? '')
          as String;
    } else if (json['categoryName'] != null) {
      category = json['categoryName'] as String;
    } else if (json['category_id'] != null || json['categoryId'] != null) {
      category = (json['categoryName'] ?? '')
          as String; // backend may choose not to provide name
    }

    String brand = '';
    if (json['brand'] is String) {
      brand = json['brand'] as String;
    } else if (json['brand'] is Map) {
      brand = (json['brand']['label'] ?? json['brand']['name'] ?? '') as String;
      brand = json['brandName'] as String;
    }

    String? categoryId;
    if (json['category_id'] != null)
      categoryId = json['category_id'].toString();
    else if (json['categoryId'] != null)
      categoryId = json['categoryId'].toString();
    else if (json['category'] is Map && json['category']['id'] != null)
      categoryId = json['category']['id'].toString();

    String? brandId;
    if (json['brand_id'] != null)
      brandId = json['brand_id'].toString();
    else if (json['brandId'] != null)
      brandId = json['brandId'].toString();
    else if (json['brand'] is Map && json['brand']['id'] != null)
      brandId = json['brand']['id'].toString();

    int quantityPerLot = 0;
    final qtyRaw = json['quantity_per_lot'] ??
        json['quantityPerBatch'] ??
        json['quantityPerLot'] ??
        json['quantity'] ??
        0;
    if (qtyRaw is int) {
      quantityPerLot = qtyRaw;
    } else if (qtyRaw is num)
      quantityPerLot = qtyRaw.toInt();
    else if (qtyRaw is String) quantityPerLot = int.tryParse(qtyRaw) ?? 0;

    List<String> specifications = [];
    final specsRaw = json['specifications'] ?? json['specs'];
    if (specsRaw is List) {
      specifications = specsRaw.map((e) => e.toString()).toList();
    } else if (specsRaw is String) {
      // comma-separated
      specifications = specsRaw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    DateTime? expirationDate;
    final exp = json['expiration_date'] ?? json['expirationDate'];
    if (exp != null && exp is String && exp.isNotEmpty) {
      try {
        expirationDate = DateTime.parse(exp);
      } catch (_) {}
    }

    double pricePerLot = 0.0;
    final priceRaw =
        json['price_per_lot'] ?? json['price'] ?? json['pricePerLot'];
    if (priceRaw != null) {
      if (priceRaw is num) {
        pricePerLot = priceRaw.toDouble();
      } else if (priceRaw is String) {
        // try parsing string numbers (may contain commas or spaces)
        final cleaned = priceRaw.replaceAll(',', '').trim();
        pricePerLot = double.tryParse(cleaned) ??
            (int.tryParse(cleaned)?.toDouble() ?? 0.0);
      }
    }

    // stock status: backend may provide a boolean `disponibility` or numeric `quantity`/`available_quantity`
    String stockStatus = 'Inconnu';
    final disponibility = json['disponibility'] ??
        json['disponible'] ??
        json['available'] ??
        json['isAvailable'];
    if (disponibility != null) {
      if (disponibility is bool) {
        stockStatus = disponibility ? 'En stock' : 'Rupture';
      } else if (disponibility is String) {
        final d = disponibility.toLowerCase();
        if (d == 'true' || d == '1' || d == 'yes' || d == 'y') {
          stockStatus = 'En stock';
        } else if (d == 'false' || d == '0' || d == 'no' || d == 'n')
          stockStatus = 'Rupture';
      } else if (disponibility is num) {
        stockStatus = disponibility > 0 ? 'En stock' : 'Rupture';
      }
    } else {
      stockStatus =
          (json['stock_status'] ?? json['stockStatus'] ?? 'Inconnu') as String;
    }

    // available quantity: try multiple keys
    int availableQuantity = 0;
    final availRaw = json['available_quantity'] ??
        json['availableQuantity'] ??
        json['quantity'] ??
        json['stock'] ??
        json['qty'];
    if (availRaw != null) {
      if (availRaw is int) {
        availableQuantity = availRaw;
      } else if (availRaw is num)
        availableQuantity = availRaw.toInt();
      else if (availRaw is String)
        availableQuantity = int.tryParse(availRaw) ?? 0;
    }

    List<String> images = [];
    final imgs = json['images'] ?? json['pictures'] ?? json['photos'];
    if (imgs is List) {
      images = imgs.map((e) => resolveImageUrl(e?.toString() ?? '')).toList();
    } else if (imgs is String && imgs.isNotEmpty) {
      images = [resolveImageUrl(imgs)];
    }
    // Some backends return a single main picture field
    final mainPic =
        json['mainpicture'] ?? json['main_picture'] ?? json['mainPicture'];
    if (mainPic != null && mainPic is String && mainPic.isNotEmpty) {
      final mainResolved = resolveImageUrl(mainPic);
      if (images.isEmpty) images = [mainResolved];
      // ensure main picture is first
      if (!images.contains(mainResolved)) images.insert(0, mainResolved);
    }

    final mainImageIndexRaw =
        json['main_image_index'] ?? json['mainImageIndex'] ?? 0;
    int mainImageIndex = 0;
    if (mainImageIndexRaw is int) {
      mainImageIndex = mainImageIndexRaw;
    } else if (mainImageIndexRaw is num)
      mainImageIndex = mainImageIndexRaw.toInt();
    else if (mainImageIndexRaw is String)
      mainImageIndex = int.tryParse(mainImageIndexRaw) ?? 0;

    return ProductModel(
      id: id,
      name: name,
      category: category,
      brand: brand,
      categoryId: categoryId,
      brandId: brandId,
      quantityPerLot: quantityPerLot,
      specifications: specifications,
      expirationDate: expirationDate,
      pricePerLot: pricePerLot,
      stockStatus: stockStatus,
      availableQuantity: availableQuantity,
      images: images,
      mainImageIndex: mainImageIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'brand': brand,
      'categoryId': categoryId,
      'brandId': brandId,
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
      categoryId: product.categoryId,
      brandId: product.brandId,
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
