import 'package:amerli_app/features/catalog/domain/entities/category.dart';

abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> items;
  CategoriesLoaded(this.items);
}

class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError(this.message);
}
