import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorits_event.dart';
import 'favorits_state.dart';
import 'package:amerli_app/features/favorits/domain/repositories/favorits_repository.dart';

class FavoritsBloc extends Bloc<FavoritsEvent, FavoritsState> {
  final FavoritsRepository repository;

  FavoritsBloc({required this.repository}) : super(FavoritsInitial()) {
    on<FavoritsLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(FavoritsLoadEvent event, Emitter<FavoritsState> emit) async {
    emit(FavoritsLoading());
    try {
      final items = await repository.getFavorits(page: event.page, pageSize: event.pageSize);
      emit(FavoritsLoaded(items));
    } catch (e) {
      emit(FavoritsError(e.toString()));
    }
  }
}



