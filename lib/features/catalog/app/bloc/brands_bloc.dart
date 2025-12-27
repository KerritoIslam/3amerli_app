import 'package:flutter_bloc/flutter_bloc.dart';
import 'brands_event.dart';
import 'brands_state.dart';
import 'package:amerli_app/features/catalog/domain/repositories/brands_repository.dart';

class BrandsBloc extends Bloc<BrandsEvent, BrandsState> {
  final BrandsRepository repository;

  BrandsBloc({required this.repository}) : super(BrandsInitial()) {
    on<BrandsLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(BrandsLoadEvent event, Emitter<BrandsState> emit) async {
    final currentState = state;
    if (event.isLoadMore && currentState is BrandsLoaded) {
      if (currentState.hasReachedMax) return;
      try {
        final nextPage = currentState.page + 1;
        final items =
            await repository.getBrands(page: nextPage, limit: event.limit);
        if (items.isEmpty) {
          emit(BrandsLoaded(currentState.items,
              hasReachedMax: true, page: currentState.page));
        } else {
          emit(BrandsLoaded(currentState.items + items,
              hasReachedMax: items.length < event.limit, page: nextPage));
        }
      } catch (e) {
        emit(BrandsError(e.toString()));
      }
    } else {
      emit(BrandsLoading());
      try {
        final items =
            await repository.getBrands(page: event.page, limit: event.limit);
        emit(BrandsLoaded(items,
            hasReachedMax: items.length < event.limit, page: event.page));
      } catch (e) {
        emit(BrandsError(e.toString()));
      }
    }
  }
}
