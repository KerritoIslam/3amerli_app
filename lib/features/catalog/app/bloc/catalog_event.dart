import 'package:equatable/equatable.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class CatalogLoadEvent extends CatalogEvent {
  final bool loadMore;
  final int pageSize;
  final String? query;

  CatalogLoadEvent({this.loadMore = false, this.pageSize = 20, this.query});

  @override
  List<Object?> get props => [loadMore, pageSize, query];
}
