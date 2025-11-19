import '../../domain/entities/card.dart';

class PaymentCardModel {
  final int id;
  final int userId;
  final String cardHolderName;
  final String last4;
  final String brand;
  final String expiry;

  PaymentCardModel({required this.id, required this.userId, required this.cardHolderName, required this.last4, required this.brand, required this.expiry});

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) => PaymentCardModel(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        userId: (json['userId'] is num) ? (json['userId'] as num).toInt() : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
        cardHolderName: json['cardHolderName']?.toString() ?? '',
        last4: json['last4']?.toString() ?? '',
        brand: json['brand']?.toString() ?? '',
        expiry: json['expiry']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'cardHolderName': cardHolderName, 'last4': last4, 'brand': brand, 'expiry': expiry};

  PaymentCard toEntity() => PaymentCard(id: id, userId: userId, cardHolderName: cardHolderName, last4: last4, brand: brand, expiry: expiry);
}
