import 'package:flutter_bloc/flutter_bloc.dart';
import 'offers_event.dart';
import 'offers_state.dart';
import 'package:amerli_app/features/catalog/domain/repositories/offers_repository.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final OffersRepository repository;

  OffersBloc({required this.repository}) : super(OffersInitial()) {
    on<OffersLoadEvent>(_onLoad);
    on<OffersCreateEvent>(_onCreate);
    on<OffersDeleteEvent>(_onDelete);
  }

  Future<void> _onLoad(OffersLoadEvent event, Emitter<OffersState> emit) async {
    emit(OffersLoading());
    try {
      final items = await repository.getOffers(page: event.page);
      emit(OffersLoaded(items));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onCreate(OffersCreateEvent event, Emitter<OffersState> emit) async {
    try {
      await repository.createOffer(event.payload);
      add(OffersLoadEvent());
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onDelete(OffersDeleteEvent event, Emitter<OffersState> emit) async {
    try {
      await repository.deleteOffer(event.id);
      add(OffersLoadEvent());
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }
}
