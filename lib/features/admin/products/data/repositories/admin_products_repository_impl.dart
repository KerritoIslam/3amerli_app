import '../../domain/entities/product.dart';
import '../../domain/repositories/admin_products_repository.dart';
import '../models/product_model.dart';

class AdminProductsRepositoryImpl implements AdminProductsRepository {
  // Mock data for demonstration
  final List<ProductModel> _products = [
    ProductModel(
      id: 'PRD001',
      name: 'Coca-Cola 1.5L',
      category: 'Boissons',
      brand: 'Coca-Cola',
      quantityPerLot: 12,
      specifications: ['1.5L', 'Gazéifiée'],
      expirationDate: DateTime(2025, 12, 31),
      pricePerLot: 1800.00,
      stockStatus: 'En stock',
      availableQuantity: 150,
      images: ['https://via.placeholder.com/150'],
      mainImageIndex: 0,
    ),
    ProductModel(
      id: 'PRD002',
      name: 'Pain de Mie',
      category: 'Boulangerie',
      brand: 'Fleur du Pays',
      quantityPerLot: 24,
      specifications: ['500g', 'Tranché'],
      expirationDate: DateTime(2025, 11, 15),
      pricePerLot: 2400.00,
      stockStatus: 'En stock',
      availableQuantity: 80,
      images: ['https://via.placeholder.com/150'],
      mainImageIndex: 0,
    ),
    ProductModel(
      id: 'PRD003',
      name: 'Lait Demi-Écrémé',
      category: 'Produits Laitiers',
      brand: 'Candia',
      quantityPerLot: 6,
      specifications: ['1L', 'UHT'],
      expirationDate: DateTime(2025, 11, 30),
      pricePerLot: 900.00,
      stockStatus: 'Rupture',
      availableQuantity: 0,
      images: ['https://via.placeholder.com/150'],
      mainImageIndex: 0,
    ),
    ProductModel(
      id: 'PRD004',
      name: 'Huile de Tournesol',
      category: 'Épicerie',
      brand: 'Elio',
      quantityPerLot: 12,
      specifications: ['1L', '100% naturelle'],
      pricePerLot: 3600.00,
      stockStatus: 'En stock',
      availableQuantity: 200,
      images: ['https://via.placeholder.com/150'],
      mainImageIndex: 0,
    ),
    ProductModel(
      id: 'PRD005',
      name: 'Riz Blanc',
      category: 'Épicerie',
      brand: 'Tassili',
      quantityPerLot: 10,
      specifications: ['1kg', 'Grain long'],
      pricePerLot: 2000.00,
      stockStatus: 'En stock',
      availableQuantity: 120,
      images: ['https://via.placeholder.com/150'],
      mainImageIndex: 0,
    ),
  ];

  @override
  Future<List<Product>> getProducts({String? query, String? category}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var filtered = _products.where((p) {
      final matchesQuery = query == null ||
          query.isEmpty ||
          p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.id.toLowerCase().contains(query.toLowerCase());
      final matchesCategory =
          category == null || category.isEmpty || p.category == category;
      return matchesQuery && matchesCategory;
    }).toList();

    return filtered;
  }

  @override
  Future<Product> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products.firstWhere((p) => p.id == id);
  }

  @override
  Future<void> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.add(ProductModel.fromEntity(product));
  }

  @override
  Future<void> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = ProductModel.fromEntity(product);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> deleteProducts(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.removeWhere((p) => ids.contains(p.id));
  }
}
