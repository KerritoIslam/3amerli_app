abstract class PaymentsEvent {}

class LoadDiscountsEvent extends PaymentsEvent {
	final int page;
	LoadDiscountsEvent({this.page = 1});
}

class LoadTransactionsEvent extends PaymentsEvent {
	final int page;
	LoadTransactionsEvent({this.page = 1});
}

class LoadCardsEvent extends PaymentsEvent {
	final int page;
	LoadCardsEvent({this.page = 1});
}

class CreateTransactionEvent extends PaymentsEvent {
	final Map<String, dynamic> payload;
	CreateTransactionEvent({required this.payload});
}

class CreateCardEvent extends PaymentsEvent {
	final Map<String, dynamic> payload;
	CreateCardEvent({required this.payload});
}
