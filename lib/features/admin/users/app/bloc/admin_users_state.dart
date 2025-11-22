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
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const AdminUsersLoaded({
    required this.users,
    this.currentQuery,
    this.currentStatusFilter,
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        users,
        currentQuery,
        currentStatusFilter,
        hasMore,
        currentPage,
        isLoadingMore
      ];

  AdminUsersLoaded copyWith({
    List<AdminUser>? users,
    String? currentQuery,
    String? currentStatusFilter,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return AdminUsersLoaded(
      users: users ?? this.users,
      currentQuery: currentQuery ?? this.currentQuery,
      currentStatusFilter: currentStatusFilter ?? this.currentStatusFilter,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class AdminUsersBlacklistLoaded extends AdminUsersState {
  final List<AdminUser> blacklistedUsers;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const AdminUsersBlacklistLoaded({
    required this.blacklistedUsers,
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props =>
      [blacklistedUsers, hasMore, currentPage, isLoadingMore];

  AdminUsersBlacklistLoaded copyWith({
    List<AdminUser>? blacklistedUsers,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return AdminUsersBlacklistLoaded(
      blacklistedUsers: blacklistedUsers ?? this.blacklistedUsers,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
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
