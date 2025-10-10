import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = await repository.fetchProfile();
        emit(ProfileLoaded(user: user));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });
  }
}
