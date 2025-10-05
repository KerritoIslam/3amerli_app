import 'package:amerli_app/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:amerli_app/features/catalog/data/models/product_model.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';

class CatalogRepositoryImpl {
  final CatalogRemoteDataSource remoteDataSource;

  CatalogRepositoryImpl({required this.remoteDataSource});

  Future<List<Product>> getProducts() async {
    final List<ProductModel> models = await remoteDataSource.fetchProducts();
    return models;
  }
}
