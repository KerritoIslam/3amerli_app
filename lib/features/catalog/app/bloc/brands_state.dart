import 'package:amerli_app/features/catalog/domain/entities/brand.dart';

abstract class BrandsState {}

class BrandsInitial extends BrandsState {}

class BrandsLoading extends BrandsState {}

class BrandsLoaded extends BrandsState {
  final List<Brand> items;
  final bool hasReachedMax;
  final int page;
  BrandsLoaded(this.items, {this.hasReachedMax = false, this.page = 1});
}

class BrandsError extends BrandsState {
  final String message;
  BrandsError(this.message);
}
