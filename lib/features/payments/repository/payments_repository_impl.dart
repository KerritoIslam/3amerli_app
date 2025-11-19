import 'package:amerli_app/features/payments/domain/entities/discount.dart';
import 'package:amerli_app/features/payments/domain/entities/transaction.dart';
import 'package:amerli_app/features/payments/domain/entities/card.dart';
import 'package:amerli_app/features/payments/domain/repositories/payments_repository.dart';
import 'package:amerli_app/features/payments/data/datasources/payments_remote_datasource.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource remoteDataSource;

  PaymentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Discount>> getDiscounts({int page = 1, int pageSize = 50}) async {
    final models = await remoteDataSource.fetchDiscounts(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TransactionEntity> createTransaction(Map<String, dynamic> payload) async {
    final model = await remoteDataSource.createTransaction(payload);
    return model.toEntity();
  }

  @override
  Future<List<TransactionEntity>> getTransactions({int page = 1, int pageSize = 50}) async {
    final models = await remoteDataSource.fetchTransactions(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PaymentCard> createCard(Map<String, dynamic> payload) async {
    final model = await remoteDataSource.createCard(payload);
    return model.toEntity();
  }

  @override
  Future<List<PaymentCard>> getCards({int page = 1, int pageSize = 50}) async {
    final models = await remoteDataSource.fetchCards(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }
}
