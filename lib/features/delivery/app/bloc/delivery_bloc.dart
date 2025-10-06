import 'package:flutter_bloc/flutter_bloc.dart';
import 'delivery_event.dart';
import 'delivery_state.dart';

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  DeliveryBloc() : super(DeliveryInitial()) {
    // placeholder
  }
}

class DeliveryInitial extends DeliveryState {}
