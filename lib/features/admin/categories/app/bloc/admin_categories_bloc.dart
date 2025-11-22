import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_categories_repository.dart';
import 'admin_categories_event.dart';
import 'admin_categories_state.dart';

class AdminCategoriesBloc
    extends Bloc<AdminCategoriesEvent, AdminCategoriesState> {
  final AdminCategoriesRepository repository;

  AdminCategoriesBloc(this.repository) : super(AdminCategoriesInitial()) {
    on<AdminCategoriesLoadEvent>(_onLoad);
    on<AdminCategoriesAddEvent>(_onAdd);
    on<AdminCategoriesUpdateEvent>(_onUpdate);
    on<AdminCategoriesDeleteEvent>(_onDelete);
    on<AdminCategoriesDeleteMultipleEvent>(_onDeleteMultiple);
    on<AdminSubCategoriesAddEvent>(_onAddSubCategory);
    on<AdminSubCategoriesUpdateEvent>(_onUpdateSubCategory);
    on<AdminSubCategoriesDeleteEvent>(_onDeleteSubCategory);
  }

  Future<void> _onLoad(
    AdminCategoriesLoadEvent event,
    Emitter<AdminCategoriesState> emit,
  ) async {
    if (event.page > 1 && state is AdminCategoriesLoaded) {
      final currentState = state as AdminCategoriesLoaded;
      if (currentState.isLoadingMore || !currentState.hasMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final newCategories = await repository.getCategories(
          query: event.query,
          page: event.page,
          limit: event.limit,
        );

        emit(currentState.copyWith(
          categories: currentState.categories + newCategories,
          filteredCategories: currentState.filteredCategories + newCategories,
          currentPage: event.page,
          hasMore: newCategories.length >= event.limit,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
      return;
    }

    emit(AdminCategoriesLoading());
    try {
      final categories = await repository.getCategories(
        query: event.query,
        page: event.page,
        limit: event.limit,
      );
      final subCategories = await repository.getSubCategories();

      emit(AdminCategoriesLoaded(
        categories: categories,
        filteredCategories: categories,
        subCategories: subCategories,
        hasMore: categories.length >= event.limit,
        currentPage: event.page,
      ));
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  Future<void> _onAdd(
    AdminCategoriesAddEvent event,
    Emitter<AdminCategoriesState> emit,
  ) async {
    try {
      await repository.addCategory(event.category);
      emit(const AdminCategoriesOperationSuccess(
          'Catégorie ajoutée avec succès'));
      add(const AdminCategoriesLoadEvent());
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    AdminCategoriesUpdateEvent event,
    Emitter<AdminCategoriesState> emit,
  ) async {
    try {
      await repository.updateCategory(event.category);
      emit(const AdminCategoriesOperationSuccess(
          'Catégorie mise à jour avec succès'));
      add(const AdminCategoriesLoadEvent());
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  Future<void> _onDelete(
    AdminCategoriesDeleteEvent event,
    Emitter<AdminCategoriesState> emit,
  ) async {
    try {
      await repository.deleteCategory(event.id);
      emit(const AdminCategoriesOperationSuccess(
          'Catégorie supprimée avec succès'));
      add(const AdminCategoriesLoadEvent());
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  Future<void> _onDeleteMultiple(
    AdminCategoriesDeleteMultipleEvent event,
    Emitter<AdminCategoriesState> emit,
  ) async {
    try {
      await repository.deleteMultipleCategories(event.ids);
      emit(AdminCategoriesOperationSuccess(
          '${event.ids.length} catégories supprimées'));
      add(const AdminCategoriesLoadEvent());
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  Future<void> _onAddSubCategory(
    AdminSubCategoriesAddEvent event,
    Emitter<AdminCategoriesState> emit,
  ) async {
    try {
      await repository.addSubCategory(event.subCategory);
      emit(const AdminCategoriesOperationSuccess(
          'Sous-catégorie ajoutée avec succès'));
      add(const AdminCategoriesLoadEvent());
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  Future<void> _onUpdateSubCategory(
    AdminSubCategoriesUpdateEvent event,
    Emitter<AdminCategoriesState> emit,
  ) async {
    try {
      await repository.updateSubCategory(event.subCategory);
      emit(const AdminCategoriesOperationSuccess(
          'Sous-catégorie mise à jour avec succès'));
      add(const AdminCategoriesLoadEvent());
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }

  Future<void> _onDeleteSubCategory(
    AdminSubCategoriesDeleteEvent event,
    Emitter<AdminCategoriesState> emit,
  ) async {
    try {
      await repository.deleteSubCategory(event.id);
      emit(const AdminCategoriesOperationSuccess(
          'Sous-catégorie supprimée avec succès'));
      add(const AdminCategoriesLoadEvent());
    } catch (e) {
      emit(AdminCategoriesError(e.toString()));
    }
  }
}
