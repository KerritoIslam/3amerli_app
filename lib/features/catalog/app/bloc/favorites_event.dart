abstract class FavoritesEvent {}

class FavoritesLoadEvent extends FavoritesEvent {
  final int page;
  FavoritesLoadEvent({this.page = 1});
}

class FavoritesAddEvent extends FavoritesEvent {
  final int userId;
  final int productId;
  FavoritesAddEvent({required this.userId, required this.productId});
}

class FavoritesRemoveEvent extends FavoritesEvent {
  final int id;
  FavoritesRemoveEvent({required this.id});
}
