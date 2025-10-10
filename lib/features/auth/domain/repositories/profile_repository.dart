import '../../domain/entities/user.dart';

abstract class ProfileRepository {
  Future<User> fetchProfile();
}
