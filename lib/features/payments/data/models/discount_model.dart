import '../../domain/entities/discount.dart';

class DiscountModel {
  final int id;
  final String code;
  final double amount;
  final String type;
  final String? expiresAt;

  DiscountModel({required this.id, required this.code, required this.amount, required this.type, this.expiresAt});

  factory DiscountModel.fromJson(Map<String, dynamic> json) => DiscountModel(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        code: json['code']?.toString() ?? '',
        amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
        type: json['type']?.toString() ?? '',
        expiresAt: json['expiresAt']?.toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'code': code, 'amount': amount, 'type': type, 'expiresAt': expiresAt};

  Discount toEntity() => Discount(id: id, code: code, amount: amount, type: type, expiresAt: expiresAt != null ? DateTime.tryParse(expiresAt!) : null);
}
