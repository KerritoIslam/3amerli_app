import 'package:amerli_app/features/catalog/domain/entities/product.dart';

/// Repository contract for catalog data living in the domain layer.
abstract class CatalogRepository {
  Future<List<Product>> getProducts({int page = 1, int pageSize = 50, String? query, bool forceRefresh = false});
}
