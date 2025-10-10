import '../../domain/entities/address.dart';

class AddressModel {
  final int id;
  final String street;
  final String district;
  final String city;

  AddressModel({required this.id, required this.street, required this.district, required this.city});

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as int,
        street: json['street'] as String,
        district: json['district'] as String,
        city: json['city'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'street': street,
        'district': district,
        'city': city,
      };

  Address toEntity() => Address(id: id, street: street, district: district, city: city);
}
