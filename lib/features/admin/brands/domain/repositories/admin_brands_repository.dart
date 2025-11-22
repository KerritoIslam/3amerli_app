import '../entities/brand.dart';

abstract class AdminBrandsRepository {
  Future<List<Brand>> getAllBrands({int page = 1, int limit = 20});
  Future<Brand> getBrandById(String id);
  Future<Brand> createBrand(String name);
  Future<Brand> updateBrand(String id, String name);
  Future<void> deleteBrand(String id);
}
