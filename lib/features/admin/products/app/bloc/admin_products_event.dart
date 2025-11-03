import '../../domain/entities/product.dart';

abstract class AdminProductsEvent {}

class AdminProductsLoadEvent extends AdminProductsEvent {
  final String? query;
  final String? category;

  AdminProductsLoadEvent({this.query, this.category});
}

class AdminProductsAddEvent extends AdminProductsEvent {
  final Product product;

  AdminProductsAddEvent(this.product);
}

class AdminProductsUpdateEvent extends AdminProductsEvent {
  final Product product;

  AdminProductsUpdateEvent(this.product);
}

class AdminProductsDeleteEvent extends AdminProductsEvent {
  final String id;

  AdminProductsDeleteEvent(this.id);
}

class AdminProductsDeleteMultipleEvent extends AdminProductsEvent {
  final List<String> ids;

  AdminProductsDeleteMultipleEvent(this.ids);
}
