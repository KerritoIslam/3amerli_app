import '../../domain/entities/offer.dart';

class OfferModel {
  final int id;
  final String title;
  final String description;
  final String startsAt;
  final String endsAt;

  OfferModel({required this.id, required this.title, required this.description, required this.startsAt, required this.endsAt});

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        startsAt: json['startsAt']?.toString() ?? '',
        endsAt: json['endsAt']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description, 'startsAt': startsAt, 'endsAt': endsAt};

  Offer toEntity() => Offer(id: id, title: title, description: description, startsAt: DateTime.tryParse(startsAt) ?? DateTime.now(), endsAt: DateTime.tryParse(endsAt) ?? DateTime.now());
}
