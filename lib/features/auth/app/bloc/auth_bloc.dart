import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LogInEvent>((event, emit) {
      // ignore: avoid_print
      print('[AuthBloc] LogInEvent received');
      emit(Authenticated());
    });
    on<LogOutEvent>((event, emit) {
      // ignore: avoid_print
      print('[AuthBloc] LogOutEvent received');
      emit(Unauthenticated());
    });
    on<ToggleAuthEvent>((event, emit) {
      // ignore: avoid_print
      print('[AuthBloc] ToggleAuthEvent received; current state: $state');
      if (state is Authenticated) {
        emit(Unauthenticated());
      } else {
        emit(Authenticated());
      }
    });
  }
}
