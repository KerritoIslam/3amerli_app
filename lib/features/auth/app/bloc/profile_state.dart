import '../../domain/entities/user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  ProfileLoaded({required this.user});
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError({required this.message});
}
