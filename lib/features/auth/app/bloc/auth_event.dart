abstract class AuthEvent {}

class LogInEvent extends AuthEvent {}
class LogOutEvent extends AuthEvent {}
class ToggleAuthEvent extends AuthEvent {}
