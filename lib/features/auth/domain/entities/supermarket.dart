import 'user.dart';

/// A Supermarket is a specialized User (sellers). Keep the same fields for now.
class Supermarket extends User {
  Supermarket({
    required int id,
    required String phoneNumber,
    required String name,
    String? locationUrl,
    int? addressId,
    String? supermarketName,
    required String? profilePic,
    required String role,
  }) : super(
          id: id,
          phoneNumber: phoneNumber,
          name: name,
          locationUrl: locationUrl,
          addressId: addressId,
          supermarketName: supermarketName,
          profilePic: profilePic,
          role: role,
        );

  /// Helper constructor to create a Supermarket from a User instance
  factory Supermarket.fromUser(User u) => Supermarket(
        id: u.id,
        phoneNumber: u.phoneNumber,
        name: u.name,
        locationUrl: u.locationUrl,
        addressId: u.addressId,
        supermarketName: u.supermarketName,
        profilePic: u.profilePic,
        role: u.role,
      );
}
