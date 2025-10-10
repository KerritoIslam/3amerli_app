import 'package:amerli_app/features/catalog/domain/entities/category.dart';
import 'package:amerli_app/features/catalog/domain/repositories/categories_repository.dart';
import 'package:amerli_app/features/catalog/data/datasources/categories_remote_datasource.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;

  CategoriesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Category>> getCategories({int page = 1, int pageSize = 50, String? query}) async {
    final models = await remoteDataSource.fetchCategories(page: page, pageSize: pageSize, query: query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Category> createCategory({required String name, String? description, String? image}) async {
    final model = await remoteDataSource.createCategory(name: name, description: description, image: image);
    return model.toEntity();
  }

  @override
  Future<Category> updateCategory(int id, {String? name, String? description, String? image}) async {
    final model = await remoteDataSource.updateCategory(id, name: name, description: description, image: image);
    return model.toEntity();
  }

  @override
  Future<void> deleteCategory(int id) async {
    await remoteDataSource.deleteCategory(id);
  }
}
