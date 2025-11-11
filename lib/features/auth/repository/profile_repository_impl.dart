import 'package:amerli_app/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:amerli_app/features/auth/data/models/user_model.dart';
import 'package:amerli_app/features/auth/domain/entities/user.dart';
import 'package:amerli_app/features/auth/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> fetchProfile() async {
    print("[profile_repo] fetchProfile start");
    try {
      final UserModel model = await remoteDataSource.fetchProfile();
      print("[profile_repo] fetchProfile remote returned model");
      // Log profilePic for debugging
      // ignore: avoid_print
      print('[profile_repo] profilePic: ${model.profilePic}');
      return model.toEntity();
    } catch (e, st) {
      // Log the full error and rethrow so callers can handle it
      // ignore: avoid_print
      print('[profile_repo] fetchProfile error: $e');
      // ignore: avoid_print
      print(st);
      rethrow;
    }
  }
}
