import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

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
    if (event.page > 1 && state is AdminUsersLoaded) {
      final currentState = state as AdminUsersLoaded;
      if (currentState.isLoadingMore || !currentState.hasMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final newUsers = await _repository.getAllUsers(
          query: event.query,
          statusFilter: event.statusFilter,
          page: event.page,
          limit: event.limit,
        );

        emit(currentState.copyWith(
          users: currentState.users + newUsers,
          currentPage: event.page,
          hasMore: newUsers.length >= event.limit,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
      return;
    }

    emit(AdminUsersLoading());
    try {
      final users = await _repository.getAllUsers(
        query: event.query,
        statusFilter: event.statusFilter,
        page: event.page,
        limit: event.limit,
      );
      emit(AdminUsersLoaded(
        users: users,
        currentQuery: event.query,
        currentStatusFilter: event.statusFilter,
        hasMore: users.length >= event.limit,
        currentPage: event.page,
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
      emit(AdminUsersOperationSuccess(
        message: AppLanguage.roleUpdated,
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
      emit(AdminUsersOperationSuccess(
        message: AppLanguage.statusUpdated,
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
      emit(AdminUsersOperationSuccess(
        message: AppLanguage.userDeleted,
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
        message: AppLanguage.usersDeleted(event.userIds.length),
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
    if (event.page > 1 && state is AdminUsersBlacklistLoaded) {
      final currentState = state as AdminUsersBlacklistLoaded;
      if (currentState.isLoadingMore || !currentState.hasMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final newUsers = await _repository.getBlacklistedUsers(
            page: event.page, limit: event.limit);

        emit(currentState.copyWith(
          blacklistedUsers: currentState.blacklistedUsers + newUsers,
          currentPage: event.page,
          hasMore: newUsers.length >= event.limit,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
      return;
    }

    emit(AdminUsersLoading());
    try {
      final users = await _repository.getBlacklistedUsers(
          page: event.page, limit: event.limit);
      emit(AdminUsersBlacklistLoaded(
        blacklistedUsers: users,
        hasMore: users.length >= event.limit,
        currentPage: event.page,
      ));
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
      emit(AdminUsersOperationSuccess(message: AppLanguage.userSuspended));
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
      emit(AdminUsersOperationSuccess(message: AppLanguage.userRestored));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }
}
