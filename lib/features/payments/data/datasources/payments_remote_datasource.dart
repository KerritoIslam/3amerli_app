import 'package:amerli_app/core/dio/api_service.dart';
import '../models/discount_model.dart';
import '../models/transaction_model.dart';
import '../models/card_model.dart';

class PaymentsRemoteDataSource {
  final ApiService apiService;

  PaymentsRemoteDataSource({required this.apiService});

  Future<List<DiscountModel>> fetchDiscounts({int page = 1, int pageSize = 50}) async {
    final response = await apiService.get('/discounts', queryParameters: {'page': page, 'pageSize': pageSize});
    final List<dynamic> list = response.data as List<dynamic>;
    return list.map((e) => DiscountModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TransactionModel> createTransaction(Map<String, dynamic> payload) async {
    final response = await apiService.post('/transactions', data: payload);
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TransactionModel>> fetchTransactions({int page = 1, int pageSize = 50}) async {
    final response = await apiService.get('/transactions', queryParameters: {'page': page, 'pageSize': pageSize});
    final List<dynamic> list = response.data as List<dynamic>;
    return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PaymentCardModel> createCard(Map<String, dynamic> payload) async {
    final response = await apiService.post('/cards', data: payload);
    return PaymentCardModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PaymentCardModel>> fetchCards({int page = 1, int pageSize = 50}) async {
    final response = await apiService.get('/cards', queryParameters: {'page': page, 'pageSize': pageSize});
    final List<dynamic> list = response.data as List<dynamic>;
    return list.map((e) => PaymentCardModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
