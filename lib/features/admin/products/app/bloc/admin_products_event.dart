import '../../domain/entities/product.dart';

abstract class AdminProductsEvent {}

class AdminProductsLoadEvent extends AdminProductsEvent {
  final String? query;
  final String? category;
  final List<int>? categoryIds;
  final List<int>? brandIds;
  final int page;
  final int limit;

  AdminProductsLoadEvent({
    this.query,
    this.category,
    this.categoryIds,
    this.brandIds,
    this.page = 1,
    this.limit = 20,
  });
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
