import 'dart:convert';

import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/features/catalog/data/models/product_model.dart';

class CatalogRemoteDataSource {
  final ApiService apiService;

  CatalogRemoteDataSource({required this.apiService});

  Future<List<ProductModel>> fetchProducts({int page = 1, int pageSize = 50, String? query}) async {
    // Mocked response for now — return static products after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    final sample = '''[
      {"id":"1","name":"Rice 50kg","description":"Bulk rice","price":750.0,"stock":20},
      {"id":"2","name":"Cooking Oil 20L","description":"Pure vegetable oil","price":450.0,"stock":10},
      {"id":"3","name":"Sugar 50kg","description":"Refined sugar","price":600.0,"stock":15}
    ]''';
    final List<dynamic> list = json.decode(sample) as List<dynamic>;
    return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
