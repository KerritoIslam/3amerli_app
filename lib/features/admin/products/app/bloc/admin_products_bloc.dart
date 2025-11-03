import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_products_repository.dart';
import 'admin_products_event.dart';
import 'admin_products_state.dart';

class AdminProductsBloc
    extends Bloc<AdminProductsEvent, AdminProductsState> {
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
    emit(AdminProductsLoading());
    try {
      final products = await repository.getProducts(
        query: event.query,
        category: event.category,
      );
      emit(AdminProductsLoaded(
        products: products,
        currentQuery: event.query,
        currentCategory: event.category,
      ));
    } catch (e) {
      emit(AdminProductsError(e.toString()));
    }
  }

  Future<void> _onAdd(
    AdminProductsAddEvent event,
    Emitter<AdminProductsState> emit,
  ) async {
    try {
      await repository.addProduct(event.product);
      emit(AdminProductsOperationSuccess('Produit ajouté avec succès'));
      // Reload products
      add(AdminProductsLoadEvent());
    } catch (e) {
      emit(AdminProductsError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    AdminProductsUpdateEvent event,
    Emitter<AdminProductsState> emit,
  ) async {
    try {
      await repository.updateProduct(event.product);
      emit(AdminProductsOperationSuccess('Produit modifié avec succès'));
      // Reload products
      add(AdminProductsLoadEvent());
    } catch (e) {
      emit(AdminProductsError(e.toString()));
    }
  }

  Future<void> _onDelete(
    AdminProductsDeleteEvent event,
    Emitter<AdminProductsState> emit,
  ) async {
    try {
      await repository.deleteProduct(event.id);
      emit(AdminProductsOperationSuccess('Produit supprimé avec succès'));
      // Reload products
      add(AdminProductsLoadEvent());
    } catch (e) {
      emit(AdminProductsError(e.toString()));
    }
  }

  Future<void> _onDeleteMultiple(
    AdminProductsDeleteMultipleEvent event,
    Emitter<AdminProductsState> emit,
  ) async {
    try {
      await repository.deleteProducts(event.ids);
      emit(AdminProductsOperationSuccess(
          '${event.ids.length} produit(s) supprimé(s) avec succès'));
      // Reload products
      add(AdminProductsLoadEvent());
    } catch (e) {
      emit(AdminProductsError(e.toString()));
    }
  }
}
