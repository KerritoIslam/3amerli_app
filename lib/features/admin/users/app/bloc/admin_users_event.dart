import 'package:equatable/equatable.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object?> get props => [];
}

class AdminUsersLoadEvent extends AdminUsersEvent {
  final String? query;
  final String? statusFilter;

  final int page;
  final int limit;

  const AdminUsersLoadEvent(
      {this.query, this.statusFilter, this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [query, statusFilter, page, limit];
}

class AdminUsersLoadDetailEvent extends AdminUsersEvent {
  final String userId;

  const AdminUsersLoadDetailEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AdminUsersUpdateRoleEvent extends AdminUsersEvent {
  final String userId;
  final String newRole;

  const AdminUsersUpdateRoleEvent({
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [userId, newRole];
}

class AdminUsersUpdateStatusEvent extends AdminUsersEvent {
  final String userId;
  final String newStatus;

  const AdminUsersUpdateStatusEvent({
    required this.userId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [userId, newStatus];
}

class AdminUsersDeleteEvent extends AdminUsersEvent {
  final String userId;

  const AdminUsersDeleteEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AdminUsersDeleteMultipleEvent extends AdminUsersEvent {
  final List<String> userIds;

  const AdminUsersDeleteMultipleEvent({required this.userIds});

  @override
  List<Object?> get props => [userIds];
}

class AdminUsersLoadRolesEvent extends AdminUsersEvent {
  const AdminUsersLoadRolesEvent();
}

class AdminUsersLoadBlacklistEvent extends AdminUsersEvent {
  final int page;
  final int limit;

  const AdminUsersLoadBlacklistEvent({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class AdminUsersAddToBlacklistEvent extends AdminUsersEvent {
  final String userId;

  const AdminUsersAddToBlacklistEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AdminUsersRestoreFromBlacklistEvent extends AdminUsersEvent {
  final String userId;

  const AdminUsersRestoreFromBlacklistEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
