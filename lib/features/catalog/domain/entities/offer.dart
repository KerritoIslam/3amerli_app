import 'package:equatable/equatable.dart';

class Offer extends Equatable {
  final int id;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;

  const Offer({required this.id, required this.title, required this.description, required this.startsAt, required this.endsAt});

  @override
  List<Object?> get props => [id, title, description, startsAt, endsAt];
}
