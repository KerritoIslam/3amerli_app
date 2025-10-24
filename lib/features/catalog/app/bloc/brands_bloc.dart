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
    emit(BrandsLoading());
    try {
      final items = await repository.getBrands();
      emit(BrandsLoaded(items));
    } catch (e) {
      emit(BrandsError(e.toString()));
    }
  }
}
