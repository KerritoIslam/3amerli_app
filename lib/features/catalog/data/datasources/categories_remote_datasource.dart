import 'dart:convert';

import 'package:amerli_app/core/dio/api_service.dart';
import '../models/category_model.dart';

class CategoriesRemoteDataSource {
  final ApiService apiService;

  CategoriesRemoteDataSource({required this.apiService});

  Future<List<CategoryModel>> fetchCategories({int page = 1, int pageSize = 50, String? query}) async {
  final Map<String, dynamic> qp = {'page': page, 'pageSize': pageSize};
    if (query != null) qp['q'] = query;
    await Future.delayed(const Duration(seconds: 2));
    final sample = '''[
      {"id":1, "name":"Rice & Grains", "description":"Rice and grains category"},
      {"id":2, "name":"Oils", "description":"Cooking oils"}
    ]''';
    final List<dynamic> list = json.decode(sample) as List<dynamic>;
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> createCategory({required String name, String? description}) async {
    await Future.delayed(const Duration(seconds: 2));
    return CategoryModel(id: 999, name: name, description: description);
  }

  Future<CategoryModel> updateCategory(int id, {String? name, String? description}) async {
    await Future.delayed(const Duration(seconds: 2));
    return CategoryModel(id: id, name: name ?? 'Updated', description: description);
  }

  Future<void> deleteCategory(int id) async {
    await Future.delayed(const Duration(seconds: 2));
    return;
  }
}
