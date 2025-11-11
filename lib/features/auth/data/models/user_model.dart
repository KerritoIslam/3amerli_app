import '../../domain/entities/user.dart';
import 'package:amerli_app/utils/image_resolver.dart';

class UserModel {
  final int id;
  final String phoneNumber;
  final String name;
  final String? locationUrl;
  final int? addressId;
  final String? supermarketName;
  final String? profilePic;
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

  factory UserModel.fromJson(Map<String, dynamic> json)  {
    // Be defensive: backend may omit some optional fields (role, location, etc.)
    final id = json['id'] as int;
    final phoneNumber = json['phoneNumber'] != null ? json['phoneNumber'].toString() : '';
    final name = json['name'] != null ? json['name'].toString() : '';
    final locationUrl = json['locationUrl'] as String?;
    final addressId = json['addressId'] as int?;
    final supermarketName = json['supermarketName'] as String?;
    final profilePic = json['profilePic'] as String?;
    final role = (json['role'] as String?) ?? '';

    return UserModel(
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'name': name,
        'locationUrl': locationUrl,
        'addressId': addressId,//TODO use adress class instead of id
        'supermarketName': supermarketName,
        'profilePic': profilePic,
        'role': role,
      };

  User toEntity()  {
    // Normalize profilePic to an absolute, network-ready URL when possible.
    final resolvedPic = (profilePic ?? '').trim().isNotEmpty ? resolveImageUrl(profilePic!) : null;
    return User(
      id: id,
      phoneNumber: phoneNumber,
      name: name,
      locationUrl: locationUrl,
      addressId: addressId,
      supermarketName: supermarketName,
      profilePic: resolvedPic,
      role: role,
    );
  }
}
