import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/features/catalog/domain/repositories/catalog_repository.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final CatalogRepository repository;
  int _currentPage = 0;
  final List<Product> _items = [];

  CatalogBloc({required this.repository}) : super(CatalogInitial()) {
    on<CatalogLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(CatalogLoadEvent event, Emitter<CatalogState> emit) async {
    try {
      // Debug logging
      // ignore: avoid_print
      print('📦 [CatalogBloc] Loading products - categoryIds: ${event.categoryIds}, brandIds: ${event.brandIds}, query: ${event.query}, loadMore: ${event.loadMore}');
      
  if (event.loadMore) {
        // If there is already loaded content, emit loading-more state with current items so UI can extend
        if (_items.isNotEmpty) emit(CatalogLoadingMore(List<Product>.from(_items), page: _currentPage, hasMore: true));
        final nextPage = _currentPage + 1;
  final List<Product> newItems = await repository.getProducts(page: nextPage, pageSize: event.pageSize, query: event.query, categoryIds: event.categoryIds, brandIds: event.brandIds);
        if (newItems.isNotEmpty) {
          _currentPage = nextPage;
          _items.addAll(newItems);
          // hasMore when newItems length == pageSize and we haven't hit the end
          final hasMore = newItems.length >= event.pageSize;
          emit(CatalogLoaded(List<Product>.from(_items), page: _currentPage, hasMore: hasMore));
        } else {
          // no more items
          emit(CatalogLoaded(List<Product>.from(_items), page: _currentPage, hasMore: false));
        }
      } else {
        // fresh load
        emit(CatalogLoading());
        _currentPage = 1;
  final List<Product> products = await repository.getProducts(page: _currentPage, pageSize: event.pageSize, query: event.query, categoryIds: event.categoryIds, brandIds: event.brandIds);
        _items.clear();
        _items.addAll(products);
        final hasMore = products.length >= event.pageSize;
        
        // Debug logging
        // ignore: avoid_print
        print('📦 [CatalogBloc] Loaded ${products.length} products, hasMore: $hasMore');
        
        emit(CatalogLoaded(List<Product>.from(_items), page: _currentPage, hasMore: hasMore));
      }
    } catch (e) {
      // ignore: avoid_print
      print('📦 [CatalogBloc] Error loading products: $e');
      emit(CatalogError(e.toString()));
    }
  }
}
