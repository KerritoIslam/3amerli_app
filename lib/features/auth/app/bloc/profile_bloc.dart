import '../../domain/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      print("ProfileBloc received LoadProfileEvent");
      emit(ProfileLoading());
      try {
        print("ProfileBloc loading profile");
        final user = await repository.fetchProfile();
        print("ProfileBloc fetched user: $user");
        emit(ProfileLoaded(user: user));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });

    on<UpdateProfilePictureEvent>((event, emit) async {
      // If we already have a loaded user, update the profilePic and re-emit
      if (state is ProfileLoaded) {
        final currentUser = (state as ProfileLoaded).user;
        final updatedUser = User(
          id: currentUser.id,
          name: currentUser.name,
          phoneNumber: currentUser.phoneNumber,
          supermarketName: currentUser.supermarketName,
          locationUrl: currentUser.locationUrl,
          addressId: currentUser.addressId,
          role: currentUser.role,
          profilePic: event.imageUrl,
          addresses: currentUser.addresses,
        );
        emit(ProfileLoaded(user: updatedUser));
      } else {
        // If profile not loaded yet, fetch it first then update
        try {
          final user = await repository.fetchProfile();
          final updatedUser = User(
            id: user.id,
            name: user.name,
            phoneNumber: user.phoneNumber,
            supermarketName: user.supermarketName,
            locationUrl: user.locationUrl,
            addressId: user.addressId,
            role: user.role,
            profilePic: event.imageUrl,
            addresses: user.addresses,
          );
          emit(ProfileLoaded(user: updatedUser));
        } catch (e) {
          emit(ProfileError(message: e.toString()));
        }
      }
    });

    on<UpdateUserInfoEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = await repository.updateProfile(event.data);
        emit(ProfileLoaded(user: user));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });
  }
}
