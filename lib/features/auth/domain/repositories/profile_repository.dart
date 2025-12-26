import '../../domain/entities/user.dart';

abstract class ProfileRepository {
  Future<User> fetchProfile();
  Future<User> updateProfile(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getAddresses();
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> addressData);
  Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> addressData);
  Future<void> deleteAddress(int id);
}
