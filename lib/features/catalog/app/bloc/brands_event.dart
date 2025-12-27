abstract class BrandsEvent {}

class BrandsLoadEvent extends BrandsEvent {
  final int page;
  final int limit;
  final bool isLoadMore;

  BrandsLoadEvent({this.page = 1, this.limit = 50, this.isLoadMore = false});
}
