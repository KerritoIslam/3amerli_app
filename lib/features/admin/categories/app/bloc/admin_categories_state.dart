import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class AdminCategoriesState extends Equatable {
  const AdminCategoriesState();

  @override
  List<Object?> get props => [];
}

class AdminCategoriesInitial extends AdminCategoriesState {}

class AdminCategoriesLoading extends AdminCategoriesState {}

class AdminCategoriesLoaded extends AdminCategoriesState {
  final List<Category> categories;
  final List<Category> filteredCategories;
  final List<SubCategory> subCategories;
  final Set<String> selectedIds;

  const AdminCategoriesLoaded({
    required this.categories,
    required this.filteredCategories,
    required this.subCategories,
    this.selectedIds = const {},
  });

  @override
  List<Object> get props => [categories, filteredCategories, subCategories, selectedIds];

  AdminCategoriesLoaded copyWith({
    List<Category>? categories,
    List<Category>? filteredCategories,
    List<SubCategory>? subCategories,
    Set<String>? selectedIds,
  }) {
    return AdminCategoriesLoaded(
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      subCategories: subCategories ?? this.subCategories,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class AdminCategoriesError extends AdminCategoriesState {
  final String message;

  const AdminCategoriesError(this.message);

  @override
  List<Object> get props => [message];
}

class AdminCategoriesOperationSuccess extends AdminCategoriesState {
  final String message;

  const AdminCategoriesOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
