import 'package:amerli_app/features/catalog/domain/entities/brand.dart';
import 'package:amerli_app/features/catalog/domain/repositories/brands_repository.dart';
import 'package:amerli_app/features/catalog/data/datasources/brands_remote_datasource.dart';

class BrandsRepositoryImpl implements BrandsRepository {
  final BrandsRemoteDataSource remoteDataSource;

  BrandsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Brand>> getBrands() async {
    final models = await remoteDataSource.fetchBrands();
    return models.map((m) => m.toEntity()).toList();
  }
}
