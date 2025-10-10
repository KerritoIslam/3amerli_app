import 'package:amerli_app/features/catalog/domain/entities/favorite.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Favorite> items;
  FavoritesLoaded(this.items);
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}
