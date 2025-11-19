import 'dart:async';

import 'package:amerli_app/core/error/failures.dart';
import 'package:amerli_app/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:amerli_app/features/catalog/data/models/product_model.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import '../domain/repositories/catalog_repository.dart';

/// Production implementation of [CatalogRepository].
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;

  // Simple in-memory cache keyed by query+page
  final Map<String, List<Product>> _cache = {};

  CatalogRepositoryImpl({required this.remoteDataSource});

  String _cacheKey({int page = 1, int pageSize = 50, String? query, List<int>? categoryIds, List<int>? brandIds}) {
    return 'p:$page|s:$pageSize|q:${query ?? ''}|c:${(categoryIds ?? []).map((e) => e.toString()).join(',')}|b:${(brandIds ?? []).map((e) => e.toString()).join(',')}';
  }

  @override
  Future<List<Product>> getProducts({int page = 1, int pageSize = 50, String? query, List<int>? categoryIds, List<int>? brandIds, bool forceRefresh = false}) async {
    final key = _cacheKey(page: page, pageSize: pageSize, query: query, categoryIds: categoryIds, brandIds: brandIds);

    if (!forceRefresh && _cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Basic retry logic
    const maxAttempts = 2;
    int attempt = 0;
    while (true) {
      try {
        attempt++;
  final List<ProductModel> models = await remoteDataSource.fetchProducts(page: page, pageSize: pageSize, query: query, categoryIds: categoryIds, brandIds: brandIds);

        final entities = models.map((m) => m.toEntity()).toList();

        // store in cache
        _cache[key] = entities;

        return entities;
      } catch (e) {
        if (attempt >= maxAttempts) {
          // Wrap in a Failure to allow higher layers to inspect type
          throw ServerFailure(e.toString());
        }
        // small backoff
        await Future.delayed(Duration(milliseconds: 200 * attempt));
      }
    }
  }
}
