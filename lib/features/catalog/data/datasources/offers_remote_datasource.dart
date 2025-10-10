import 'dart:convert';

import 'package:amerli_app/core/dio/api_service.dart';
import '../models/offer_model.dart';

class OffersRemoteDataSource {
  final ApiService apiService;

  OffersRemoteDataSource({required this.apiService});

  Future<List<OfferModel>> fetchOffers({int page = 1, int pageSize = 50}) async {
    // Development/mock implementation: return sample offers with a small delay
    await Future.delayed(const Duration(seconds: 2));
    final sample = '''[
      {"id":1, "title":"Summer Sale", "description":"Up to 30% off on selected items", "startsAt":"2025-06-01T00:00:00Z", "endsAt":"2025-06-30T23:59:59Z"},
      {"id":2, "title":"Buy 1 Get 1", "description":"Buy one get one free on snacks", "startsAt":"2025-07-01T00:00:00Z", "endsAt":"2025-07-07T23:59:59Z"}
    ]''';
    final List<dynamic> list = jsonDecode(sample) as List<dynamic>;
    return list.map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OfferModel> createOffer(Map<String, dynamic> payload) async {
    // Mock create: echo back payload with a fake id
    await Future.delayed(const Duration(seconds: 1));
    final Map<String, dynamic> result = Map<String, dynamic>.from(payload);
    result['id'] = DateTime.now().millisecondsSinceEpoch % 100000;
    return OfferModel.fromJson(result);
  }

  Future<void> deleteOffer(int id) async {
    // Mock delete: simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }
}
