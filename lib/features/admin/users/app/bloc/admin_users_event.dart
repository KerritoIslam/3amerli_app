import 'package:equatable/equatable.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object?> get props => [];
}

class AdminUsersLoadEvent extends AdminUsersEvent {
  final String? query;
  final String? statusFilter;

  const AdminUsersLoadEvent({this.query, this.statusFilter});

  @override
  List<Object?> get props => [query, statusFilter];
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
