import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';
import 'package:amerli_app/features/catalog/domain/repositories/favorites_repository.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository repository;

  FavoritesBloc({required this.repository}) : super(FavoritesInitial()) {
    on<FavoritesLoadEvent>(_onLoad);
    on<FavoritesAddEvent>(_onAdd);
    on<FavoritesRemoveEvent>(_onRemove);
  }

  Future<void> _onLoad(FavoritesLoadEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final items = await repository.getFavorites(page: event.page);
      emit(FavoritesLoaded(items));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onAdd(FavoritesAddEvent event, Emitter<FavoritesState> emit) async {
    try {
      await repository.addFavorite(userId: event.userId, productId: event.productId);
      add(FavoritesLoadEvent());
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onRemove(FavoritesRemoveEvent event, Emitter<FavoritesState> emit) async {
    try {
      await repository.removeFavorite(event.id);
      add(FavoritesLoadEvent());
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
