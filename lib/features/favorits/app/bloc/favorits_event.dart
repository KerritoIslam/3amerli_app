abstract class FavoritsEvent {}

class FavoritsLoadEvent extends FavoritsEvent {
  final int page;
  final int pageSize;
  FavoritsLoadEvent({this.page = 1, this.pageSize = 20});
}



