import 'package:amerli_app/features/catalog/domain/entities/category.dart';
import 'package:amerli_app/features/catalog/domain/repositories/categories_repository.dart';
import 'package:amerli_app/features/catalog/data/datasources/categories_remote_datasource.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;

  CategoriesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Category>> getCategories({int page = 1, int pageSize = 50, String? query}) async {
    // Backend exposes a simple main-categories endpoint without pagination/query
    final models = await remoteDataSource.fetchCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Category> createCategory({required String name, String? description, String? image}) async {
    // Map domain fields to API payload (label == name). parentId not exposed by domain here.
    final model = await remoteDataSource.createCategory(label: name);
    return model.toEntity();
  }

  @override
  Future<Category> updateCategory(int id, {String? name, String? description, String? image}) async {
    // Map domain 'name' to API 'label'
    await remoteDataSource.updateCategory(id, label: name);
    // The API returns no body for update; fetch updated category via children/main endpoint isn't available,
    // so return a simple entity using provided values when possible.
    return Category(id: id, name: name ?? '', description: description, image: image);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await remoteDataSource.deleteCategory(id);
  }
}
