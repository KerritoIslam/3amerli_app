import 'package:amerli_app/features/auth/domain/entities/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
	final User user;
	Authenticated(this.user);
}

class Unauthenticated extends AuthState {}
