import '../entities/category.dart';

abstract class AdminCategoriesRepository {
  Future<List<Category>> getCategories(
      {String? query, int page = 1, int limit = 20});
  Future<List<SubCategory>> getSubCategories({String? categoryId});
  Future<Category> getCategory(String id);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> deleteMultipleCategories(List<String> ids);
  Future<void> addSubCategory(SubCategory subCategory);
  Future<void> updateSubCategory(SubCategory subCategory);
  Future<void> deleteSubCategory(String id);
}
