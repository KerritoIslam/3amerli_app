import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import '../../repository/catalog_repository_impl.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final CatalogRepositoryImpl repository;

  CatalogBloc({required this.repository}) : super(CatalogInitial()) {
    on<CatalogLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(CatalogLoadEvent event, Emitter<CatalogState> emit) async {
    emit(CatalogLoading());
    try {
      final List<Product> products = await repository.getProducts();
      emit(CatalogLoaded(products));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}
