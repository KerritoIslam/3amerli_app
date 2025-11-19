abstract class CategoriesEvent {}

class CategoriesLoadEvent extends CategoriesEvent {
  final int page;
  final String? query;
  CategoriesLoadEvent({this.page = 1, this.query});
}

class CategoriesCreateEvent extends CategoriesEvent {
  final String name;
  final String? description;
  final String? image;
  CategoriesCreateEvent({required this.name, this.description, this.image});
}

class CategoriesUpdateEvent extends CategoriesEvent {
  final int id;
  final String? name;
  final String? description;
  final String? image;
  CategoriesUpdateEvent({required this.id, this.name, this.description, this.image});
}

class CategoriesDeleteEvent extends CategoriesEvent {
  final int id;
  CategoriesDeleteEvent({required this.id});
}
