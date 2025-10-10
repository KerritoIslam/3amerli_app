import 'package:flutter_bloc/flutter_bloc.dart';
import 'payments_event.dart';
import 'payments_state.dart';
import 'package:amerli_app/features/payments/domain/repositories/payments_repository.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentsRepository repository;

  PaymentsBloc({required this.repository}) : super(PaymentsInitial()) {
    on<LoadDiscountsEvent>(_onLoadDiscounts);
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadCardsEvent>(_onLoadCards);
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<CreateCardEvent>(_onCreateCard);
  }

  Future<void> _onLoadDiscounts(LoadDiscountsEvent event, Emitter<PaymentsState> emit) async {
    emit(PaymentsLoading());
    try {
      final items = await repository.getDiscounts(page: event.page);
      emit(DiscountsLoaded(items));
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  Future<void> _onLoadTransactions(LoadTransactionsEvent event, Emitter<PaymentsState> emit) async {
    emit(PaymentsLoading());
    try {
      final items = await repository.getTransactions(page: event.page);
      emit(TransactionsLoaded(items));
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  Future<void> _onLoadCards(LoadCardsEvent event, Emitter<PaymentsState> emit) async {
    emit(PaymentsLoading());
    try {
      final items = await repository.getCards(page: event.page);
      emit(CardsLoaded(items));
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  Future<void> _onCreateTransaction(CreateTransactionEvent event, Emitter<PaymentsState> emit) async {
    try {
      await repository.createTransaction(event.payload);
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  Future<void> _onCreateCard(CreateCardEvent event, Emitter<PaymentsState> emit) async {
    try {
      await repository.createCard(event.payload);
      add(LoadCardsEvent());
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }
}
