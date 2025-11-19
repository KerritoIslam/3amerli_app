import 'package:amerli_app/features/catalog/domain/entities/category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> getCategories({int page = 1, int pageSize = 50, String? query});
  Future<Category> createCategory({required String name, String? description, String? image});
  Future<Category> updateCategory(int id, {String? name, String? description, String? image});
  Future<void> deleteCategory(int id);
}
