import 'package:amerli_app/features/catalog/domain/entities/product.dart';

abstract class FavoritsRepository {
  Future<List<Product>> getFavorits({int page = 1, int pageSize = 20});
}



