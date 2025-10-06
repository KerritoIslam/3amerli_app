import 'package:flutter_bloc/flutter_bloc.dart';
import 'payments_event.dart';
import 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  PaymentsBloc() : super(PaymentsInitial()) {
    // placeholder
  }
}

class PaymentsInitial extends PaymentsState {}
