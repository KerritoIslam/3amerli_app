import '../entities/product.dart';

abstract class AdminProductsRepository {
  Future<List<Product>> getProducts({String? query, String? category});
  Future<Product> getProductById(String id);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> deleteProducts(List<String> ids);
}
