import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/features/catalog/data/models/product_model.dart';
import 'package:amerli_app/features/favorits/data/datasources/favorits_remote_datasource.dart';
import 'package:amerli_app/features/favorits/domain/repositories/favorits_repository.dart';

class FavoritsRepositoryImpl implements FavoritsRepository {
  final FavoritsRemoteDataSource remote;

  FavoritsRepositoryImpl({required this.remote});

  @override
  Future<List<Product>> getFavorits({int page = 1, int pageSize = 20}) async {
    final List<ProductModel> models = await remote.fetchFavoritProducts(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }
}



