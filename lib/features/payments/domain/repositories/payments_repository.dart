import 'package:amerli_app/features/payments/domain/entities/discount.dart';
import 'package:amerli_app/features/payments/domain/entities/transaction.dart';
import 'package:amerli_app/features/payments/domain/entities/card.dart';

abstract class PaymentsRepository {
  Future<List<Discount>> getDiscounts({int page = 1, int pageSize = 50});
  Future<TransactionEntity> createTransaction(Map<String, dynamic> payload);
  Future<List<TransactionEntity>> getTransactions({int page = 1, int pageSize = 50});
  Future<PaymentCard> createCard(Map<String, dynamic> payload);
  Future<List<PaymentCard>> getCards({int page = 1, int pageSize = 50});
}
