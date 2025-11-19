import 'user.dart';

/// A Supermarket is a specialized User (sellers). Keep the same fields for now.
class Supermarket extends User {
  Supermarket({
    required super.id,
    required super.phoneNumber,
    required super.name,
    super.locationUrl,
    super.addressId,
    super.supermarketName,
    required super.profilePic,
    required super.role,
  });

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
