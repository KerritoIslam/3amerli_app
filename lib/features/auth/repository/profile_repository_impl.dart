import 'package:amerli_app/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:amerli_app/features/auth/data/models/user_model.dart';
import 'package:amerli_app/features/auth/domain/entities/user.dart';
import 'package:amerli_app/features/auth/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> fetchProfile() async {
    final UserModel model = await remoteDataSource.fetchProfile();
    return model.toEntity();
  }
}
