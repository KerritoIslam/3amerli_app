import 'package:amerli_app/core/dio/api_service.dart';
import '../models/offer_model.dart';

class OffersRemoteDataSource {
  final ApiService apiService;

  OffersRemoteDataSource({required this.apiService});

  Future<List<OfferModel>> fetchOffers({int page = 1, int pageSize = 50}) async {
    final response = await apiService.get('/offers', queryParameters: {'page': page, 'pageSize': pageSize});
    final List<dynamic> list = response.data as List<dynamic>;
    return list.map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OfferModel> createOffer(Map<String, dynamic> payload) async {
    final response = await apiService.post('/offers', data: payload);
    return OfferModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteOffer(int id) async {
    await apiService.delete('/offers/$id');
  }
}
