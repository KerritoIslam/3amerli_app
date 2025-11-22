import '../../domain/entities/product.dart';

abstract class AdminProductsState {}

class AdminProductsInitial extends AdminProductsState {}

class AdminProductsLoading extends AdminProductsState {}

class AdminProductsLoaded extends AdminProductsState {
  final List<Product> products;
  final String? currentQuery;
  final String? currentCategory;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  AdminProductsLoaded({
    required this.products,
    this.currentQuery,
    this.currentCategory,
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  AdminProductsLoaded copyWith({
    List<Product>? products,
    String? currentQuery,
    String? currentCategory,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return AdminProductsLoaded(
      products: products ?? this.products,
      currentQuery: currentQuery ?? this.currentQuery,
      currentCategory: currentCategory ?? this.currentCategory,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class AdminProductsError extends AdminProductsState {
  final String message;

  AdminProductsError(this.message);
}

class AdminProductsOperationSuccess extends AdminProductsState {
  final String message;

  AdminProductsOperationSuccess(this.message);
}
