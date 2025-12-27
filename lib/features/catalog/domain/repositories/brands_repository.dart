import '../entities/brand.dart';

abstract class BrandsRepository {
  Future<List<Brand>> getBrands({int page = 1, int limit = 50});
}
