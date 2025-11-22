import 'package:amerli_app/core/dio/api_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/admin_categories_repository.dart';

class AdminCategoriesRepositoryImpl implements AdminCategoriesRepository {
  final ApiService apiService;

  AdminCategoriesRepositoryImpl({required this.apiService});

  List _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    if (data is Map && data['items'] is List) return data['items'] as List;
    return [];
  }

  @override
  Future<List<Category>> getCategories(
      {String? query, int page = 1, int limit = 20}) async {
    final qp = <String, dynamic>{};
    if (query != null && query.isNotEmpty) qp['search'] = query;
    qp['page'] = page;
    qp['limit'] = limit;
    final resp = await apiService.get('/categories/main-categories',
        queryParameters: qp);
    final list = _extractList(resp.data);
    return list.map<Category>((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return Category(
        id: m['id']?.toString() ?? '',
        name: m['label'] ?? m['name'] ?? '',
        description: m['description'] ?? '',
        imageUrl: m['picture'] ?? m['imageUrl'] ?? '',
        productCount: (m['productCount'] as num?)?.toInt() ?? 0,
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'])
            : DateTime.now(),
        updatedAt: m['updatedAt'] != null
            ? DateTime.parse(m['updatedAt'])
            : DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<List<SubCategory>> getSubCategories({String? categoryId}) async {
    if (categoryId == null || categoryId.isEmpty) {
      // Fallback to main categories call
      return [];
    }
    final resp = await apiService.get('/categories/$categoryId/children');
    final list = _extractList(resp.data);
    return list.map<SubCategory>((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return SubCategory(
        id: m['id']?.toString() ?? '',
        name: m['label'] ?? m['name'] ?? '',
        categoryId: categoryId,
        categoryName: m['parentLabel'] ?? '',
        productCount: (m['productCount'] as num?)?.toInt() ?? 0,
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'])
            : DateTime.now(),
        updatedAt: m['updatedAt'] != null
            ? DateTime.parse(m['updatedAt'])
            : DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<Category> getCategory(String id) async {
    final resp = await apiService.get('/categories/$id');
    if (resp.data is Map) {
      final m = Map<String, dynamic>.from(resp.data as Map);
      return Category(
        id: m['id']?.toString() ?? '',
        name: m['label'] ?? m['name'] ?? '',
        description: m['description'] ?? '',
        imageUrl: m['picture'] ?? m['imageUrl'] ?? '',
        productCount: (m['productCount'] as num?)?.toInt() ?? 0,
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'])
            : DateTime.now(),
        updatedAt: m['updatedAt'] != null
            ? DateTime.parse(m['updatedAt'])
            : DateTime.now(),
      );
    }
    throw Exception('Unexpected category response');
  }

  // Mutating methods remain unsupported in this remote implementation for now
  @override
  Future<void> addCategory(Category category) async => throw UnsupportedError(
      'addCategory not implemented for remote admin API');

  @override
  Future<void> updateCategory(Category category) async =>
      throw UnsupportedError(
          'updateCategory not implemented for remote admin API');

  @override
  Future<void> deleteCategory(String id) async => throw UnsupportedError(
      'deleteCategory not implemented for remote admin API');

  @override
  Future<void> deleteMultipleCategories(List<String> ids) async =>
      throw UnsupportedError(
          'deleteMultipleCategories not implemented for remote admin API');

  @override
  Future<void> addSubCategory(SubCategory subCategory) async =>
      throw UnsupportedError(
          'addSubCategory not implemented for remote admin API');

  @override
  Future<void> updateSubCategory(SubCategory subCategory) async =>
      throw UnsupportedError(
          'updateSubCategory not implemented for remote admin API');

  @override
  Future<void> deleteSubCategory(String id) async => throw UnsupportedError(
      'deleteSubCategory not implemented for remote admin API');
}
