import 'package:amerli_app/features/catalog/domain/entities/product.dart';

abstract class FavoritsState {}

class FavoritsInitial extends FavoritsState {}

class FavoritsLoading extends FavoritsState {}

class FavoritsLoaded extends FavoritsState {
  final List<Product> products;
  FavoritsLoaded(this.products);
}

class FavoritsError extends FavoritsState {
  final String message;
  FavoritsError(this.message);
}



 