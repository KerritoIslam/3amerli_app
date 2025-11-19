import 'package:equatable/equatable.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final List<Product> products;
  final int page;
  final bool hasMore;

  const CatalogLoaded(this.products, {this.page = 1, this.hasMore = true});

  @override
  List<Object?> get props => [products, page, hasMore];
}

class CatalogLoadingMore extends CatalogState {
  final List<Product> products;
  final int page;
  final bool hasMore;

  const CatalogLoadingMore(this.products, {this.page = 1, this.hasMore = true});

  @override
  List<Object?> get props => [products, page, hasMore];
}

class CatalogError extends CatalogState {
  final String message;
  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}
