import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class AdminCategoriesEvent extends Equatable {
  const AdminCategoriesEvent();

  @override
  List<Object?> get props => [];
}

class AdminCategoriesLoadEvent extends AdminCategoriesEvent {
  final String? query;

  const AdminCategoriesLoadEvent({this.query});

  @override
  List<Object?> get props => [query];
}

class AdminCategoriesAddEvent extends AdminCategoriesEvent {
  final Category category;

  const AdminCategoriesAddEvent(this.category);

  @override
  List<Object> get props => [category];
}

class AdminCategoriesUpdateEvent extends AdminCategoriesEvent {
  final Category category;

  const AdminCategoriesUpdateEvent(this.category);

  @override
  List<Object> get props => [category];
}

class AdminCategoriesDeleteEvent extends AdminCategoriesEvent {
  final String id;

  const AdminCategoriesDeleteEvent(this.id);

  @override
  List<Object> get props => [id];
}

class AdminCategoriesDeleteMultipleEvent extends AdminCategoriesEvent {
  final List<String> ids;

  const AdminCategoriesDeleteMultipleEvent(this.ids);

  @override
  List<Object> get props => [ids];
}

class AdminSubCategoriesAddEvent extends AdminCategoriesEvent {
  final SubCategory subCategory;

  const AdminSubCategoriesAddEvent(this.subCategory);

  @override
  List<Object> get props => [subCategory];
}

class AdminSubCategoriesUpdateEvent extends AdminCategoriesEvent {
  final SubCategory subCategory;

  const AdminSubCategoriesUpdateEvent(this.subCategory);

  @override
  List<Object> get props => [subCategory];
}

class AdminSubCategoriesDeleteEvent extends AdminCategoriesEvent {
  final String id;

  const AdminSubCategoriesDeleteEvent(this.id);

  @override
  List<Object> get props => [id];
}
