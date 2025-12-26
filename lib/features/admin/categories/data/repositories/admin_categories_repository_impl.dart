import 'package:dio/dio.dart';
import 'package:amerli_app/core/dio/api_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/admin_categories_repository.dart';
import '../models/category_model.dart';

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

  Never _handleError(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        if (msg is List) throw Exception(msg.join('\n'));
        throw Exception(msg.toString());
      }
    }
    throw e;
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
        imageUrl: m['pictureUrl'] ?? m['picture'] ?? m['imageUrl'] ?? '',
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
    final String endpoint = (categoryId == null || categoryId.isEmpty)
        ? '/categories/subcategories/all'
        : '/categories/$categoryId/children';

    final resp = await apiService.get(endpoint);
    final list = _extractList(resp.data);
    return list.map<SubCategory>((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return SubCategoryModel.fromJson(m).toEntity();
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
        imageUrl: m['pictureUrl'] ?? m['picture'] ?? m['imageUrl'] ?? '',
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
  Future<void> addCategory(Category category) async {
    try {
      final map = <String, dynamic>{'label': category.name};
      if (category.parentId != null) {
        map['parentCategoryId'] = category.parentId;
      }
      final formData = FormData.fromMap(map);

      if (category.imageUrl != null &&
          category.imageUrl!.isNotEmpty &&
          !category.imageUrl!.startsWith('http')) {
        final file = await MultipartFile.fromFile(
          category.imageUrl!,
          filename: category.imageUrl!.split('/').last,
        );
        formData.files.add(MapEntry('picture', file));
      }

      await apiService.post('/categories', data: formData);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      final map = <String, dynamic>{'label': category.name};
      // Send newParentCategoryId as string. 'null' string removes parent, empty string keeps it.
      // If category.parentId is null, we assume we want to remove the parent (make it root).
      // If category.parentId is set, we set it as the new parent.
      map['newParentCategoryId'] = category.parentId ?? 'null';

      final formData = FormData.fromMap(map);

      if (category.imageUrl != null &&
          category.imageUrl!.isNotEmpty &&
          !category.imageUrl!.startsWith('http')) {
        final file = await MultipartFile.fromFile(
          category.imageUrl!,
          filename: category.imageUrl!.split('/').last,
        );
        formData.files.add(MapEntry('picture', file));
      }

      await apiService.put('/categories/${category.id}', data: formData);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await apiService.delete('/categories/$id');
    } catch (e) {
      _handleError(e);
    }
  }

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
