import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(DashboardInitial()) {
    on<DashboardLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(DashboardLoadEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final stats = await repository.getDashboardStats();
      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
