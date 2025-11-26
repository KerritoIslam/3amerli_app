import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/core/error/error_handler.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import '../../domain/repositories/admin_products_repository.dart';
import 'admin_products_event.dart';
import 'admin_products_state.dart';

class AdminProductsBloc extends Bloc<AdminProductsEvent, AdminProductsState> {
  final AdminProductsRepository repository;

  AdminProductsBloc(this.repository) : super(AdminProductsInitial()) {
    on<AdminProductsLoadEvent>(_onLoad);
    on<AdminProductsAddEvent>(_onAdd);
    on<AdminProductsUpdateEvent>(_onUpdate);
    on<AdminProductsDeleteEvent>(_onDelete);
    on<AdminProductsDeleteMultipleEvent>(_onDeleteMultiple);
  }

  Future<void> _onLoad(
    AdminProductsLoadEvent event,
    Emitter<AdminProductsState> emit,
  ) async {
    if (event.page > 1 && state is AdminProductsLoaded) {
      final currentState = state as AdminProductsLoaded;
      if (currentState.isLoadingMore || !currentState.hasMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final newProducts = await repository.getProducts(
          query: event.query,
          category: event.category,
          categoryIds: event.categoryIds,
          brandIds: event.brandIds,
          page: event.page,
          limit: event.limit,
        );

        emit(currentState.copyWith(
          products: currentState.products + newProducts,
          currentPage: event.page,
          hasMore: newProducts.length >= event.limit,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
      return;
    }

    emit(AdminProductsLoading());
    try {
      final products = await repository.getProducts(
        query: event.query,
        category: event.category,
        categoryIds: event.categoryIds,
        brandIds: event.brandIds,
        page: event.page,
        limit: event.limit,
      );

      emit(AdminProductsLoaded(
        products: products,
        currentQuery: event.query,
        currentCategory: event.category,
        hasMore: products.length >= event.limit,
        currentPage: event.page,
      ));
    } catch (e) {
      emit(AdminProductsError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onAdd(
    AdminProductsAddEvent event,
    Emitter<AdminProductsState> emit,
  ) async {
    try {
      await repository.addProduct(event.product);
      emit(AdminProductsOperationSuccess(AppLanguage.saveSuccess));
      // Reload products
      add(AdminProductsLoadEvent());
    } catch (e) {
      emit(AdminProductsError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUpdate(
    AdminProductsUpdateEvent event,
    Emitter<AdminProductsState> emit,
  ) async {
    try {
      await repository.updateProduct(event.product);
      emit(AdminProductsOperationSuccess(AppLanguage.updateSuccess));
      // Reload products
      add(AdminProductsLoadEvent());
    } catch (e) {
      emit(AdminProductsError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onDelete(
    AdminProductsDeleteEvent event,
    Emitter<AdminProductsState> emit,
  ) async {
    try {
      await repository.deleteProduct(event.id);
      emit(AdminProductsOperationSuccess(AppLanguage.deleteSuccess));
      // Reload products
      add(AdminProductsLoadEvent());
    } catch (e) {
      emit(AdminProductsError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onDeleteMultiple(
    AdminProductsDeleteMultipleEvent event,
    Emitter<AdminProductsState> emit,
  ) async {
    try {
      await repository.deleteProducts(event.ids);
      emit(AdminProductsOperationSuccess(AppLanguage.deleteSuccess));
      // Reload products
      add(AdminProductsLoadEvent());
    } catch (e) {
      emit(AdminProductsError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
