import 'package:flutter_bloc/flutter_bloc.dart';
import 'categories_event.dart';
import 'categories_state.dart';
import 'package:amerli_app/features/catalog/domain/repositories/categories_repository.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesRepository repository;

  CategoriesBloc({required this.repository}) : super(CategoriesInitial()) {
    on<CategoriesLoadEvent>(_onLoad);
    on<CategoriesCreateEvent>(_onCreate);
    on<CategoriesUpdateEvent>(_onUpdate);
    on<CategoriesDeleteEvent>(_onDelete);
  }

  Future<void> _onLoad(CategoriesLoadEvent event, Emitter<CategoriesState> emit) async {
    emit(CategoriesLoading());
    try {
      final items = await repository.getCategories(page: event.page, query: event.query);
      emit(CategoriesLoaded(items));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> _onCreate(CategoriesCreateEvent event, Emitter<CategoriesState> emit) async {
    try {
      await repository.createCategory(name: event.name, description: event.description);
      add(CategoriesLoadEvent());
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> _onUpdate(CategoriesUpdateEvent event, Emitter<CategoriesState> emit) async {
    try {
      await repository.updateCategory(event.id, name: event.name, description: event.description);
      add(CategoriesLoadEvent());
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> _onDelete(CategoriesDeleteEvent event, Emitter<CategoriesState> emit) async {
    try {
      await repository.deleteCategory(event.id);
      add(CategoriesLoadEvent());
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}
