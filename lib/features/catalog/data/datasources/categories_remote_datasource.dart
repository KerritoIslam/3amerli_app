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
      {"id":3, "name":"Beverages", "description":"Drinks and beverages", "image":"https://picsum.photos/seed/beverages/200/200", "products": [{"id":301, "name":"Orange Juice", "description":"Fresh", "price":3.5, "stock":50}], "subcategories": [
          {"id":31, "name":"Juices", "description":"Fruit juices", "image":"https://picsum.photos/seed/juice/200/200", "products": [{"id":311, "name":"Apple Juice", "description":"Fresh Apple", "price":2.5, "stock":30}]},
          {"id":32, "name":"Sodas", "description":"Carbonated drinks", "image":"https://picsum.photos/seed/soda/200/200", "products": [{"id":321, "name":"Cola", "description":"Classic Cola", "price":1.5, "stock":80}]}
        ]},
      {"id":4, "name":"Snacks", "description":"Chips and snacks", "image":"https://picsum.photos/seed/snacks/200/200", "products": [{"id":401, "name":"Potato Chips", "description":"Salted", "price":1.2, "stock":100}], "subcategories": [
          {"id":41, "name":"Chips", "description":"Potato and plantain chips", "image":"https://picsum.photos/seed/chips/200/200", "products": [{"id":411, "name":"Plantain Chips", "description":"Crispy", "price":1.0, "stock":45}]},
          {"id":42, "name":"Biscuits", "description":"Sweet and savory biscuits", "image":"https://picsum.photos/seed/biscuits/200/200", "products": [{"id":421, "name":"Butter Biscuits", "description":"Soft", "price":0.9, "stock":120}]}
        ]}
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
