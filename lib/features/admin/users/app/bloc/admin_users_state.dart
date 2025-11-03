import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_user.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<AdminUser> users;
  final String? currentQuery;
  final String? currentStatusFilter;

  const AdminUsersLoaded({
    required this.users,
    this.currentQuery,
    this.currentStatusFilter,
  });

  @override
  List<Object?> get props => [users, currentQuery, currentStatusFilter];
}

class AdminUserDetailLoaded extends AdminUsersState {
  final AdminUser user;

  const AdminUserDetailLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class AdminUsersRolesLoaded extends AdminUsersState {
  final List<UserRole> roles;

  const AdminUsersRolesLoaded({required this.roles});

  @override
  List<Object?> get props => [roles];
}

class AdminUsersOperationSuccess extends AdminUsersState {
  final String message;

  const AdminUsersOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminUsersError extends AdminUsersState {
  final String message;

  const AdminUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}
