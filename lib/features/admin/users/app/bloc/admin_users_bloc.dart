import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/admin_users_repository.dart';
import 'admin_users_event.dart';
import 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final AdminUsersRepository _repository;

  AdminUsersBloc({required AdminUsersRepository repository})
      : _repository = repository,
        super(AdminUsersInitial()) {
    on<AdminUsersLoadEvent>(_onLoad);
    on<AdminUsersLoadDetailEvent>(_onLoadDetail);
    on<AdminUsersUpdateRoleEvent>(_onUpdateRole);
    on<AdminUsersUpdateStatusEvent>(_onUpdateStatus);
    on<AdminUsersDeleteEvent>(_onDelete);
    on<AdminUsersDeleteMultipleEvent>(_onDeleteMultiple);
    on<AdminUsersLoadRolesEvent>(_onLoadRoles);
    on<AdminUsersLoadBlacklistEvent>(_onLoadBlacklist);
    on<AdminUsersAddToBlacklistEvent>(_onAddToBlacklist);
    on<AdminUsersRestoreFromBlacklistEvent>(_onRestoreFromBlacklist);
  }

  Future<void> _onLoad(
    AdminUsersLoadEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      final users = await _repository.getAllUsers(
        query: event.query,
        statusFilter: event.statusFilter,
      );
      emit(AdminUsersLoaded(
        users: users,
        currentQuery: event.query,
        currentStatusFilter: event.statusFilter,
      ));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onLoadDetail(
    AdminUsersLoadDetailEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      final user = await _repository.getUserById(event.userId);
      emit(AdminUserDetailLoaded(user: user));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRole(
    AdminUsersUpdateRoleEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.updateUserRole(event.userId, event.newRole);
      emit(const AdminUsersOperationSuccess(
        message: 'Rôle mis à jour avec succès',
      ));
      // Reload detail to show updated user
      add(AdminUsersLoadDetailEvent(userId: event.userId));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    AdminUsersUpdateStatusEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.updateUserStatus(event.userId, event.newStatus);
      emit(const AdminUsersOperationSuccess(
        message: 'Statut mis à jour avec succès',
      ));
      // Reload detail to show updated user
      add(AdminUsersLoadDetailEvent(userId: event.userId));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onDelete(
    AdminUsersDeleteEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.deleteUser(event.userId);
      emit(const AdminUsersOperationSuccess(
        message: 'Utilisateur supprimé avec succès',
      ));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onDeleteMultiple(
    AdminUsersDeleteMultipleEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.deleteMultipleUsers(event.userIds);
      emit(AdminUsersOperationSuccess(
        message: '${event.userIds.length} utilisateur(s) supprimé(s) avec succès',
      ));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onLoadRoles(
    AdminUsersLoadRolesEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      final roles = await _repository.getRoles();
      emit(AdminUsersRolesLoaded(roles: roles));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onLoadBlacklist(
    AdminUsersLoadBlacklistEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      final users = await _repository.getBlacklistedUsers(page: event.page, limit: event.limit);
      emit(AdminUsersBlacklistLoaded(blacklistedUsers: users));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onAddToBlacklist(
    AdminUsersAddToBlacklistEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.addToBlacklist(event.userId);
      emit(const AdminUsersOperationSuccess(message: 'Utilisateur suspendu avec succès'));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onRestoreFromBlacklist(
    AdminUsersRestoreFromBlacklistEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      await _repository.restoreFromBlacklist(event.userId);
      emit(const AdminUsersOperationSuccess(message: 'Utilisateur restauré avec succès'));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }
}
