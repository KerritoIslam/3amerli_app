import '../entities/brand.dart';

abstract class BrandsRepository {
  Future<List<Brand>> getBrands();
}
