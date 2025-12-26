import 'address.dart';

class User {
  final int id;
  final String phoneNumber;
  final String name;
  final String? locationUrl;
  final int? addressId;
  final String? supermarketName;
  final String? profilePic;
  final String role;

  final List<Address>? addresses;

  User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.locationUrl,
    this.addressId,
    this.supermarketName,
    required this.profilePic,
    required this.role,
    this.addresses,
  });

  String get address {
    if (addresses != null && addresses!.isNotEmpty) {
      return addresses!.first.toString();
    }
    return locationUrl ?? '';
  }
}

