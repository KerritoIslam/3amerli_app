import 'dart:convert';

import 'package:amerli_app/core/dio/api_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/admin_products_repository.dart';
import '../models/product_model.dart';

class AdminProductsRepositoryImpl implements AdminProductsRepository {
  final ApiService apiService;

  AdminProductsRepositoryImpl({required this.apiService});

  List _extractList(dynamic data) {
    // Defensive extraction for many possible response shapes.
    if (data == null) return [];

    // If server returned a JSON string, try to decode it
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return _extractList(decoded);
      } catch (_) {
        return [];
      }
    }

    if (data is List) return data;

    if (data is Map) {
      // common keys that hold lists
      final candidates = ['data', 'items', 'rows', 'result', 'docs'];
      for (final key in candidates) {
        final v = data[key];
        if (v is List) return v;
        // sometimes `data` is an object with nested list under 'data' or 'items'
        if (v is Map) {
          for (final nestedKey in candidates) {
            final nv = v[nestedKey];
            if (nv is List) return nv;
          }
        }
      }

      // fallback: sometimes the desired list is the first list found in the map
      for (final entry in data.entries) {
        if (entry.value is List) return entry.value as List;
      }
    }

    return [];
  }

  @override
  Future<List<Product>> getProducts({String? query, String? category}) async {
    final qp = <String, dynamic>{};
    if (query != null && query.isNotEmpty) qp['search'] = query;
    // If category looks like an id list (comma separated) pass as categoryIds
    if (category != null && category.isNotEmpty) qp['categoryIds'] = category;

    final resp = await apiService.get('/products/admin/all', queryParameters: qp);
    final list = _extractList(resp.data);

    // Debug: print extracted length and a preview to help diagnose empty UI
    try {
      // ignore: avoid_print
      print('[ADMIN PRODUCTS] extracted list length: ${list.length}');
      if (list.isNotEmpty) {
        // ignore: avoid_print
        print('[ADMIN PRODUCTS] first item preview: ${list.first}');
      }
    } catch (_) {}

    final results = <Product>[];
    for (final e in list) {
      try {
        if (e is Map) {
          final map = Map<String, dynamic>.from(e);
          // Ensure id is a string (models expect string id)
          if (map['id'] is num) map['id'] = (map['id'] as num).toString();
          results.add(ProductModel.fromJson(map));
        } else if (e is String) {
          // try to decode a JSON encoded object
          try {
            final decoded = jsonDecode(e);
            if (decoded is Map) {
              final map = Map<String, dynamic>.from(decoded);
              if (map['id'] is num) map['id'] = (map['id'] as num).toString();
              results.add(ProductModel.fromJson(map));
            }
          } catch (_) {
            // skip malformed string entry
            // ignore: avoid_print
            print('[ADMIN PRODUCTS] skipped malformed string entry');
          }
        } else {
          // skip unsupported entry types
          // ignore: avoid_print
          print('[ADMIN PRODUCTS] skipped unsupported entry type: ${e.runtimeType}');
        }
      } catch (ex, st) {
        // ignore: avoid_print
        print('[ADMIN PRODUCTS] mapping error: $ex\n$st');
      }
    }

    return results;
  }

  @override
  Future<Product> getProductById(String id) async {
    final resp = await apiService.get('/products/$id');
    if (resp.data is Map) {
      final map = Map<String, dynamic>.from(resp.data as Map);
      if (map['id'] is num) map['id'] = (map['id'] as num).toString();
      return ProductModel.fromJson(map);
    }
    throw Exception('Unexpected product response');
  }

  // Create/update/delete are still not implemented against multipart endpoints.
  // Keep the existing signatures but throw to avoid accidental use.
  @override
  Future<void> addProduct(Product product) async =>
      throw UnsupportedError('addProduct not implemented for remote admin API');

  @override
  Future<void> updateProduct(Product product) async =>
      throw UnsupportedError('updateProduct not implemented for remote admin API');

  @override
  Future<void> deleteProduct(String id) async =>
      throw UnsupportedError('deleteProduct not implemented for remote admin API');

  @override
  Future<void> deleteProducts(List<String> ids) async =>
      throw UnsupportedError('deleteProducts not implemented for remote admin API');
}
