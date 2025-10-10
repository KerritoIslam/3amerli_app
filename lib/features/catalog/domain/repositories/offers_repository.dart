import 'package:amerli_app/features/catalog/domain/entities/offer.dart';

abstract class OffersRepository {
  Future<List<Offer>> getOffers({int page = 1, int pageSize = 50});
  Future<Offer> createOffer(Map<String, dynamic> payload);
  Future<void> deleteOffer(int id);
}
