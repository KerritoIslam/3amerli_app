import 'package:amerli_app/features/catalog/domain/entities/category.dart';
import 'package:amerli_app/features/catalog/domain/repositories/categories_repository.dart';
import 'package:amerli_app/features/catalog/data/datasources/categories_remote_datasource.dart';
import 'package:amerli_app/features/catalog/data/models/category_model.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;

  CategoriesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Category>> getCategories(
      {int page = 1, int pageSize = 50, String? query}) async {
    // 1. Fetch main categories
    final mainModels = await remoteDataSource.fetchCategories();

    // 2. Fetch all subcategories
    final subModels = await remoteDataSource.fetchAllSubCategories();

    // 3. Stitch them together
    // Create a map of main categories for easy lookup/modification
    // We use a new list of models to avoid mutating the original fixed-length lists if any
    final mainMap = <int, CategoryModel>{};
    for (var m in mainModels) {
      // Create a copy with empty subcategories list to populate
      mainMap[m.id] = CategoryModel(
        id: m.id,
        name: m.name,
        description: m.description,
        image: m.image,
        products: m.products,
        subcategories: [], // Start empty
        parentId: m.parentId,
      );
    }

    // Distribute subcategories to their parents
    for (var s in subModels) {
      if (s.parentId != null && mainMap.containsKey(s.parentId)) {
        mainMap[s.parentId]!.subcategories.add(s);
      }
    }

    // Return the values of the map converted to entities
    return mainMap.values.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Category> createCategory(
      {required String name, String? description, String? image}) async {
    // Map domain fields to API payload (label == name). parentId not exposed by domain here.
    final model = await remoteDataSource.createCategory(label: name);
    return model.toEntity();
  }

  @override
  Future<Category> updateCategory(int id,
      {String? name, String? description, String? image}) async {
    // Map domain 'name' to API 'label'
    await remoteDataSource.updateCategory(id, label: name);
    // The API returns no body for update; fetch updated category via children/main endpoint isn't available,
    // so return a simple entity using provided values when possible.
    return Category(
        id: id, name: name ?? '', description: description, image: image);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await remoteDataSource.deleteCategory(id);
  }
}
