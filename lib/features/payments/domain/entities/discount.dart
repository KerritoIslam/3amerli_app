import 'package:equatable/equatable.dart';

class Discount extends Equatable {
  final int id;
  final String code;
  final double amount; // either flat or percentage depending on type
  final String type; // 'flat' or 'percent'
  final DateTime? expiresAt;

  const Discount({required this.id, required this.code, required this.amount, required this.type, this.expiresAt});

  @override
  List<Object?> get props => [id, code, amount, type, expiresAt];
}
