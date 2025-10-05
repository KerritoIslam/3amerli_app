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
  const CatalogLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class CatalogError extends CatalogState {
  final String message;
  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}
