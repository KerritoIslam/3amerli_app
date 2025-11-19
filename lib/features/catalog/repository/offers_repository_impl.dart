import 'package:amerli_app/features/catalog/domain/entities/offer.dart';
import 'package:amerli_app/features/catalog/domain/repositories/offers_repository.dart';
import 'package:amerli_app/features/catalog/data/datasources/offers_remote_datasource.dart';

class OffersRepositoryImpl implements OffersRepository {
  final OffersRemoteDataSource remoteDataSource;

  OffersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Offer>> getOffers({int page = 1, int pageSize = 50}) async {
    final models = await remoteDataSource.fetchOffers(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Offer> createOffer(Map<String, dynamic> payload) async {
    final model = await remoteDataSource.createOffer(payload);
    return model.toEntity();
  }

  @override
  Future<void> deleteOffer(int id) async {
    await remoteDataSource.deleteOffer(id);
  }
}
