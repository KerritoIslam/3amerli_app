import 'package:amerli_app/features/payments/domain/entities/discount.dart';
import 'package:amerli_app/features/payments/domain/entities/transaction.dart';
import 'package:amerli_app/features/payments/domain/entities/card.dart';

abstract class PaymentsState {}

class PaymentsInitial extends PaymentsState {}

class PaymentsLoading extends PaymentsState {}

class DiscountsLoaded extends PaymentsState {
	final List<Discount> items;
	DiscountsLoaded(this.items);
}

class TransactionsLoaded extends PaymentsState {
	final List<TransactionEntity> items;
	TransactionsLoaded(this.items);
}

class CardsLoaded extends PaymentsState {
	final List<PaymentCard> items;
	CardsLoaded(this.items);
}

class PaymentsError extends PaymentsState {
	final String message;
	PaymentsError(this.message);
}
