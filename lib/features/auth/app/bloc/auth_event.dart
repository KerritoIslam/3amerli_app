import 'package:amerli_app/features/auth/domain/entities/user.dart';

abstract class AuthEvent {}

class LogInEvent extends AuthEvent {
	final User user;
	LogInEvent(this.user);
}

class LogOutEvent extends AuthEvent {}

class ToggleAuthEvent extends AuthEvent {}
