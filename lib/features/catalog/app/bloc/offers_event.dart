abstract class OffersEvent {}

class OffersLoadEvent extends OffersEvent {
  final int page;
  OffersLoadEvent({this.page = 1});
}

class OffersCreateEvent extends OffersEvent {
  final Map<String, dynamic> payload;
  OffersCreateEvent({required this.payload});
}

class OffersDeleteEvent extends OffersEvent {
  final int id;
  OffersDeleteEvent({required this.id});
}
