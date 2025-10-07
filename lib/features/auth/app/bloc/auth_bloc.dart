import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../utils/helpers/logger.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LogInEvent>((event, emit) {
      logInfo('[AuthBloc] LogInEvent received');
      emit(Authenticated());
    });
    on<LogOutEvent>((event, emit) {
      logInfo('[AuthBloc] LogOutEvent received');
      emit(Unauthenticated());
    });
    on<ToggleAuthEvent>((event, emit) {
      logInfo('[AuthBloc] ToggleAuthEvent received; current state: $state');
      if (state is Authenticated) {
        emit(Unauthenticated());
      } else {
        emit(Authenticated());
      }
    });
  }
}
