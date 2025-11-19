import 'package:flutter_bloc/flutter_bloc.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';
import 'package:amerli_app/features/notifications/domain/repositories/notifications_repository.dart';
// entity import not required directly here

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository repository;

  NotificationsBloc({required this.repository}) : super(NotificationsInitial()) {
    on<NotificationsLoadEvent>(_onLoad);
    on<NotificationsMarkAllReadEvent>(_onMarkAllRead);
    on<NotificationsToggleReadEvent>(_onToggleRead);
    on<NotificationsDeleteEvent>(_onDelete);
  }

  Future<void> _onLoad(NotificationsLoadEvent event, Emitter<NotificationsState> emit) async {
    emit(NotificationsLoading());
    try {
      final items = await repository.getNotifications(page: event.page, pageSize: event.pageSize);
      // debug
      // ignore: avoid_print
      print('NotificationsBloc: fetched ${items.length} items');
      // keep only last 7 days (backend policy: max 7 days available to delete)
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      final filtered = items.where((i) => i.createdAt.isAfter(cutoff)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // ignore: avoid_print
      print('NotificationsBloc: filtered to ${filtered.length} items after 7-day cutoff');
      emit(NotificationsLoaded(filtered));
    } catch (e) {
      // ignore: avoid_print
      print('NotificationsBloc: load error: $e');
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkAllRead(NotificationsMarkAllReadEvent event, Emitter<NotificationsState> emit) async {
    final current = state;
    if (current is NotificationsLoaded) {
      try {
        final unreadIds = current.items.where((e) => !e.read).map((e) => e.id).toList();
        if (unreadIds.isNotEmpty) {
          await repository.markMultipleRead(unreadIds);
        }
        // refresh
        add(NotificationsLoadEvent());
      } catch (e) {
        // ignore: avoid_print
        print('NotificationsBloc: mark all read error: $e');
        emit(NotificationsError(e.toString()));
      }
    }
  }

  Future<void> _onToggleRead(NotificationsToggleReadEvent event, Emitter<NotificationsState> emit) async {
    final current = state;
    if (current is NotificationsLoaded) {
      try {
        await repository.markRead(event.notification.id);
        add(NotificationsLoadEvent());
      } catch (e) {
        // ignore: avoid_print
        print('NotificationsBloc: toggle read error: $e');
        emit(NotificationsError(e.toString()));
      }
    }
  }

  Future<void> _onDelete(NotificationsDeleteEvent event, Emitter<NotificationsState> emit) async {
    try {
      await repository.deleteNotification(event.id);
      // Refresh the list after deletion
      add(NotificationsLoadEvent());
    } catch (e) {
      // ignore: avoid_print
      print('NotificationsBloc: delete error: $e');
      emit(NotificationsError(e.toString()));
    }
  }
}
