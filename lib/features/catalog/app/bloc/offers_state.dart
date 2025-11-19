import 'package:amerli_app/features/catalog/domain/entities/offer.dart';

abstract class OffersState {}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersLoaded extends OffersState {
  final List<Offer> items;
  OffersLoaded(this.items);
}

class OffersError extends OffersState {
  final String message;
  OffersError(this.message);
}
