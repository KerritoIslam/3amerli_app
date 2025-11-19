import 'package:equatable/equatable.dart';

class PaymentCard extends Equatable {
  final int id;
  final int userId;
  final String cardHolderName;
  final String last4;
  final String brand;
  final String expiry; // MM/YY or ISO

  const PaymentCard({required this.id, required this.userId, required this.cardHolderName, required this.last4, required this.brand, required this.expiry});

  @override
  List<Object?> get props => [id, userId, cardHolderName, last4, brand, expiry];
}
