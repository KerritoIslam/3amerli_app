import 'package:amerli_app/features/catalog/domain/entities/product.dart';

/// Repository contract for catalog data living in the domain layer.
abstract class CatalogRepository {
  /// Get products with optional pagination, search and category filtering.
  ///
  /// - [page]: page number (default 1)
  /// - [pageSize]: items per page (default 50)
  /// - [query]: search term
  /// - [categoryIds]: optional list of category ids to filter by
  /// - [brandIds]: optional list of brand ids to filter by
  /// - [forceRefresh]: bypass cache
  Future<List<Product>> getProducts({int page = 1, int pageSize = 50, String? query, List<int>? categoryIds, List<int>? brandIds, bool forceRefresh = false});
}
