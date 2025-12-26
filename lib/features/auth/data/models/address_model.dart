import '../../domain/entities/address.dart';

class AddressModel extends Address {
  AddressModel({
    required super.id,
    super.street,
    super.city,
    super.district,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      street: json['street'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'street': street,
        'city': city,
        'district': district,
      };
}
