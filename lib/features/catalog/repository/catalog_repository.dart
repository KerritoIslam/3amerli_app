import 'package:amerli_app/features/catalog/domain/entities/product.dart';

/// Repository contract for catalog data.
abstract class CatalogRepository {
  /// Fetch products from the repository.
  ///
  /// - [page] and [pageSize] are for pagination support; implementations may
  ///   ignore them if the data source does not support paging yet.
  /// - [query] can be used to search/filter on the server.
  /// - [forceRefresh] bypasses any local cache.
  Future<List<Product>> getProducts({int page = 1, int pageSize = 50, String? query, bool forceRefresh = false});
}
