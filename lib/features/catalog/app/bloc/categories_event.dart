abstract class CategoriesEvent {}

class CategoriesLoadEvent extends CategoriesEvent {
  final int page;
  final String? query;
  CategoriesLoadEvent({this.page = 1, this.query});
}

class CategoriesCreateEvent extends CategoriesEvent {
  final String name;
  final String? description;
  CategoriesCreateEvent({required this.name, this.description});
}

class CategoriesUpdateEvent extends CategoriesEvent {
  final int id;
  final String? name;
  final String? description;
  CategoriesUpdateEvent({required this.id, this.name, this.description});
}

class CategoriesDeleteEvent extends CategoriesEvent {
  final int id;
  CategoriesDeleteEvent({required this.id});
}
