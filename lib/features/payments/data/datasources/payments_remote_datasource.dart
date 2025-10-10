import 'dart:convert';

import 'package:amerli_app/core/dio/api_service.dart';
import '../models/discount_model.dart';
import '../models/transaction_model.dart';
import '../models/card_model.dart';

class PaymentsRemoteDataSource {
  final ApiService apiService;

  PaymentsRemoteDataSource({required this.apiService});

  Future<List<DiscountModel>> fetchDiscounts({int page = 1, int pageSize = 50}) async {
    await Future.delayed(const Duration(seconds: 2));
    final sample = '''[
      {"id":1, "code":"WELCOME", "amount":50.0, "type":"flat", "expiresAt":null}
    ]''';
    final List<dynamic> list = json.decode(sample) as List<dynamic>;
    return list.map((e) => DiscountModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TransactionModel> createTransaction(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(seconds: 2));
    final result = {'id': 999, ...payload, 'createdAt': DateTime.now().toIso8601String()};
    return TransactionModel.fromJson(result);
  }

  Future<List<TransactionModel>> fetchTransactions({int page = 1, int pageSize = 50}) async {
    await Future.delayed(const Duration(seconds: 2));
    final sample = '''[
      {"id":1, "userId":1, "amount":1200.0, "status":"paid", "createdAt":"2025-10-10T00:00:00Z"}
    ]''';
    final List<dynamic> list = json.decode(sample) as List<dynamic>;
    return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PaymentCardModel> createCard(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(seconds: 2));
    final result = {'id': 777, ...payload};
    return PaymentCardModel.fromJson(result);
  }

  Future<List<PaymentCardModel>> fetchCards({int page = 1, int pageSize = 50}) async {
    await Future.delayed(const Duration(seconds: 2));
    final sample = '''[
      {"id":1, "userId":1, "cardHolderName":"John Doe", "last4":"4242", "brand":"Visa", "expiry":"12/25"}
    ]''';
    final List<dynamic> list = json.decode(sample) as List<dynamic>;
    return list.map((e) => PaymentCardModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
