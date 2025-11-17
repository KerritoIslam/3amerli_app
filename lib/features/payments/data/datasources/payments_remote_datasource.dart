import 'dart:convert';
import 'dart:developer' as developer;

import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:dio/dio.dart';

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
    // Call backend /order endpoint which may return an order object and checkoutUrl
    bool isSuccess(int? status) => status != null && status >= 200 && status < 300;

    try {
      developer.log('createTransaction payload: $payload', name: 'PaymentsRemoteDataSource');
      final resp = await apiService.post('/order', data: payload);
      if (isSuccess(resp.statusCode) && resp.data != null) {
        // TransactionModel.fromJson handles multiple shapes (checkoutUrl at top-level or inside 'order')
        final data = resp.data;
        developer.log('createTransaction response: $data', name: 'PaymentsRemoteDataSource');
        if (data is Map<String, dynamic>) return TransactionModel.fromJson(data);
        if (data is Map) return TransactionModel.fromJson(Map<String, dynamic>.from(data));
        // fallback
        return TransactionModel.fromJson({'id': -1, 'userId': payload['buyerId'] ?? 0, 'amount': payload['totalAmount'] ?? payload['amount'] ?? 0.0, 'status': 'PENDING', 'createdAt': DateTime.now().toIso8601String(), 'checkoutUrl': null});
      }

      final msg = resp.data is Map && resp.data['message'] != null ? resp.data['message'].toString() : 'Failed to create transaction';
      throw ApiException(msg, statusCode: resp.statusCode, serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;
      final baseMsg = e.message ?? 'Network error while creating transaction';
      final detailed = 'status: ${status ?? 'unknown'} | $baseMsg | serverResponse: ${serverResp ?? 'null'}';
      developer.log('Dio error createTransaction - status: $status, serverResponse: $serverResp', name: 'PaymentsRemoteDataSource', error: e, stackTrace: StackTrace.current, level: 1000);
      throw ApiException(detailed, statusCode: status, isNetworkError: true, serverResponse: serverResp);
    }
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
