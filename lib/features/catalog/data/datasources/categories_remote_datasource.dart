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
      {"id":1, "name":"Rice & Grains", "description":"Rice and grains category", "image":"https://picsum.photos/seed/rice/200/200", "products": [{"id":101, "name":"Basmati Rice", "description":"Long grain basmati", "price":12.5, "stock":20}]},
      {"id":2, "name":"Oils", "description":"Cooking oils", "image":"https://picsum.photos/seed/oils/200/200", "products": [{"id":201, "name":"Olive Oil", "description":"Extra virgin", "price":8.0, "stock":15}]},
      {"id":3, "name":"Beverages", "description":"Drinks and beverages", "image":"https://picsum.photos/seed/beverages/200/200", "products": [{"id":301, "name":"Orange Juice", "description":"Fresh", "price":3.5, "stock":50}]},
      {"id":4, "name":"Snacks", "description":"Chips and snacks", "image":"https://picsum.photos/seed/snacks/200/200", "products": [{"id":401, "name":"Potato Chips", "description":"Salted", "price":1.2, "stock":100}]}
    ]''';
    final List<dynamic> list = json.decode(sample) as List<dynamic>;
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> createCategory({required String name, String? description, String? image}) async {
    await Future.delayed(const Duration(seconds: 2));
    return CategoryModel(id: 999, name: name, description: description, image: image);
  }

  Future<CategoryModel> updateCategory(int id, {String? name, String? description, String? image}) async {
    await Future.delayed(const Duration(seconds: 2));
    return CategoryModel(id: id, name: name ?? 'Updated', description: description, image: image);
  }

  Future<void> deleteCategory(int id) async {
    await Future.delayed(const Duration(seconds: 2));
    return;
  }
}
