import '../../domain/entities/product.dart';

abstract class AdminProductsState {}

class AdminProductsInitial extends AdminProductsState {}

class AdminProductsLoading extends AdminProductsState {}

class AdminProductsLoaded extends AdminProductsState {
  final List<Product> products;
  final String? currentQuery;
  final String? currentCategory;

  AdminProductsLoaded({
    required this.products,
    this.currentQuery,
    this.currentCategory,
  });
}

class AdminProductsError extends AdminProductsState {
  final String message;

  AdminProductsError(this.message);
}

class AdminProductsOperationSuccess extends AdminProductsState {
  final String message;

  AdminProductsOperationSuccess(this.message);
}
