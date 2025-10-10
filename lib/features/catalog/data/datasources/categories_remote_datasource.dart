import 'package:amerli_app/core/dio/api_service.dart';
import '../models/category_model.dart';

class CategoriesRemoteDataSource {
  final ApiService apiService;

  CategoriesRemoteDataSource({required this.apiService});

  Future<List<CategoryModel>> fetchCategories({int page = 1, int pageSize = 50, String? query}) async {
  final Map<String, dynamic> qp = {'page': page, 'pageSize': pageSize};
    if (query != null) qp['q'] = query;
    final response = await apiService.get('/categories', queryParameters: qp);
    final List<dynamic> list = response.data as List<dynamic>;
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> createCategory({required String name, String? description}) async {
    final response = await apiService.post('/categories', data: {'name': name, 'description': description});
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CategoryModel> updateCategory(int id, {String? name, String? description}) async {
    final response = await apiService.put('/categories/$id', data: {'name': name, 'description': description});
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    await apiService.delete('/categories/$id');
  }
}
