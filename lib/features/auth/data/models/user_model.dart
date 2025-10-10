import '../../domain/entities/user.dart';

class UserModel {
  final int id;
  final String phoneNumber;
  final String name;
  final String? locationUrl;
  final int? addressId;
  final String? supermarketName;
  final String profilePic;
  final String role;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.locationUrl,
    this.addressId,
    this.supermarketName,
    required this.profilePic,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        phoneNumber: json['phoneNumber'] as String,
        name: json['name'] as String,
        locationUrl: json['locationUrl'] as String?,
        addressId: json['addressId'] as int?,
        supermarketName: json['supermarketName'] as String?,
        profilePic: json['profilePic'] as String,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'name': name,
        'locationUrl': locationUrl,
        'addressId': addressId,
        'supermarketName': supermarketName,
        'profilePic': profilePic,
        'role': role,
      };

  User toEntity() => User(
        id: id,
        phoneNumber: phoneNumber,
        name: name,
        locationUrl: locationUrl,
        addressId: addressId,
        supermarketName: supermarketName,
        profilePic: profilePic,
        role: role,
      );
}
