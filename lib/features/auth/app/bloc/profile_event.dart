abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfilePictureEvent extends ProfileEvent {
  final String imageUrl;
  UpdateProfilePictureEvent({required this.imageUrl});
}

class UpdateUserInfoEvent extends ProfileEvent {
  final Map<String, dynamic> data;
  UpdateUserInfoEvent({required this.data});
}
