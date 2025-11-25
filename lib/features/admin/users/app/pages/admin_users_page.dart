import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../utils/constants/app_colors.dart';
import '../../../../../widgets/searchbar.dart';
import '../../domain/entities/admin_user.dart';
import '../bloc/admin_users_bloc.dart';
import '../bloc/admin_users_event.dart';
import '../bloc/admin_users_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:amerli_app/core/utils/top_toast.dart';
import 'package:amerli_app/core/utils/csv_export_helper.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _selectedTab = 'all';
  String _searchQuery = '';
  final Set<String> _selectedUserIds = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AdminUsersBloc>().state;
      if (state is AdminUsersLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<AdminUsersBloc>().add(AdminUsersLoadEvent(
              query: state.currentQuery,
              statusFilter: state.currentStatusFilter,
              page: state.currentPage + 1,
              limit: 20,
            ));
      } else if (state is AdminUsersBlacklistLoaded &&
          state.hasMore &&
          !state.isLoadingMore) {
        context.read<AdminUsersBloc>().add(AdminUsersLoadBlacklistEvent(
              page: state.currentPage + 1,
              limit: 20,
            ));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    if (_selectedTab == 'suspended') {
      // Load from blacklist endpoint
      context.read<AdminUsersBloc>().add(const AdminUsersLoadBlacklistEvent());
    } else {
      // Load all users
      context.read<AdminUsersBloc>().add(AdminUsersLoadEvent(
            query: _searchQuery.isEmpty ? null : _searchQuery,
            statusFilter: null,
            page: 1,
            limit: 20,
          ));
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _loadUsers();
  }

  void _onTabChanged(String tab) {
    setState(() {
      _selectedTab = tab;
      _selectedUserIds.clear();
    });
    _loadUsers();
  }

  Future<void> _onExportCSV() async {
    final state = context.read<AdminUsersBloc>().state;
    List<AdminUser> usersToExport = [];

    if (state is AdminUsersLoaded) {
      usersToExport = state.users;
    } else if (state is AdminUsersBlacklistLoaded) {
      usersToExport = state.blacklistedUsers;
    }

    if (usersToExport.isEmpty) {
      TopToast.show(context, AppLanguage.noUsersToExport, isError: true);
      return;
    }

    try {
      final headers = [
        AppLanguage.id,
        AppLanguage.name,
        AppLanguage.phone,
        AppLanguage.role,
        AppLanguage.status,
        AppLanguage.storeName,
        AppLanguage.address
      ];

      final data = usersToExport.map((u) {
        return [
          u.id,
          u.name,
          u.phone,
          u.role,
          u.status,
          u.storeName ?? '',
          u.address ?? '',
        ];
      }).toList();

      await CsvExportHelper.exportToCsv(
        fileName: 'users_export_${DateTime.now().millisecondsSinceEpoch}',
        headers: headers,
        data: data,
      );
    } catch (e) {
      if (!mounted) return;
      TopToast.show(context, AppLanguage.csvExportError, isError: true);
    }
  }

  void _onDeleteSelected() {
    if (_selectedUserIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLanguage.confirmDelete),
          content: Text(
            '${AppLanguage.confirmDeleteUsers} (${_selectedUserIds.length})',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLanguage.cancel),
            ),
            TextButton(
              onPressed: () {
                context.read<AdminUsersBloc>().add(
                      AdminUsersDeleteMultipleEvent(
                        userIds: _selectedUserIds.toList(),
                      ),
                    );
                Navigator.of(dialogContext).pop();
                setState(() {
                  _selectedUserIds.clear();
                });
                _loadUsers();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(AppLanguage.delete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Header (centered title)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppLanguage.users,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Compact Search + Export row (match products: 40px height)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                              height: 40,
                              child:
                                  AppSearchbar(onChanged: _onSearchChanged))),
                      const SizedBox(width: 8),
                      if (_selectedUserIds.isNotEmpty) ...[
                        ElevatedButton(
                          onPressed: _onDeleteSelected,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            minimumSize: const Size(0, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                              '${AppLanguage.delete} (${_selectedUserIds.length})',
                              style: const TextStyle(fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      ElevatedButton(
                        onPressed: _onExportCSV,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(AppLanguage.exportCSV,
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _TabButton(
                      label: AppLanguage.all,
                      isSelected: _selectedTab == 'all',
                      onTap: () => _onTabChanged('all'),
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      label: AppLanguage.suspended,
                      isSelected: _selectedTab == 'suspended',
                      onTap: () => _onTabChanged('suspended'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Users Table
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadUsers();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: BlocConsumer<AdminUsersBloc, AdminUsersState>(
                      listener: (context, state) {
                        if (state is AdminUsersOperationSuccess) {
                          TopToast.show(context, state.message);
                          _loadUsers();
                        }
                      },
                      builder: (context, state) {
                        if (state is AdminUsersLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is AdminUsersLoaded) {
                          return Column(
                            children: [
                              _buildUsersTable(state.users),
                              if (state.isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                            ],
                          );
                        } else if (state is AdminUsersBlacklistLoaded) {
                          return Column(
                            children: [
                              _buildUsersTable(state.blacklistedUsers),
                              if (state.isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                            ],
                          );
                        } else if (state is AdminUsersError) {
                          return Center(child: Text(state.message));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersTable(List<AdminUser> users) {
    // Filter out delivery/livreur roles entirely from the admin users table
    final filteredUsers = users.where((u) {
      final rk = u.role.toLowerCase();
      return !(rk.contains('livreur') || rk.contains('delivery'));
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightPrimary, width: 1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Table Header (reduced vertical padding for denser rows)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Select All Checkbox
                      SizedBox(
                        width: 24,
                        child: Checkbox(
                          value:
                              _selectedUserIds.length == filteredUsers.length &&
                                  filteredUsers.isNotEmpty,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedUserIds
                                    .addAll(filteredUsers.map((u) => u.id));
                              } else {
                                _selectedUserIds.clear();
                              }
                            });
                          },
                          shape: const CircleBorder(),
                          activeColor: AppColors.brandDeep,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: Text(
                          AppLanguage.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 3,
                        child: Text(
                          AppLanguage.phone,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 3,
                        child: Text(
                          AppLanguage.role,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 80,
                        child: Text(
                          AppLanguage.actions,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Body (use filtered users)
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                    ),
                    itemBuilder: (context, index) {
                      final u = filteredUsers[index];
                      return _UserRow(
                        user: u,
                        isSelected: _selectedUserIds.contains(u.id),
                        onSelectionChanged: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedUserIds.add(u.id);
                            } else {
                              _selectedUserIds.remove(u.id);
                            }
                          });
                        },
                        onView: () {
                          context.push('/admin/users/${u.id}');
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Text(AppLanguage.confirmDelete),
                                content: Text(
                                  '${AppLanguage.confirmDeleteUser} (${u.name})',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                    child: Text(AppLanguage.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<AdminUsersBloc>().add(
                                            AdminUsersDeleteEvent(
                                              userId: u.id,
                                            ),
                                          );
                                      Navigator.of(dialogContext).pop();
                                      _loadUsers();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: Text(AppLanguage.delete),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onSuspendToggle: () {
                          if (_selectedTab == 'suspended') {
                            // User is in blacklist, restore them
                            context.read<AdminUsersBloc>().add(
                                  AdminUsersRestoreFromBlacklistEvent(
                                      userId: u.id),
                                );
                          } else {
                            // User is not in blacklist, add them
                            context.read<AdminUsersBloc>().add(
                                  AdminUsersAddToBlacklistEvent(userId: u.id),
                                );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPrimary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final AdminUser user;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final VoidCallback? onSuspendToggle;

  const _UserRow({
    required this.user,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onView,
    required this.onDelete,
    this.onSuspendToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectionChanged(value ?? false),
              shape: const CircleBorder(),
              activeColor: AppColors.brandDeep,
            ),
          ),

          const SizedBox(width: 6),

          // Name
          Expanded(
            flex: 3,
            child: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 4),

          // Phone
          Expanded(
            flex: 3,
            child: Text(
              user.phone,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 4),

          // Role Badge with role-specific colors
          Expanded(
            flex: 3,
            child: Builder(builder: (context) {
              final roleKey = user.role.toLowerCase();
              Color textColor = AppColors.lightPrimary;
              Color bgColor = AppColors.lightPrimary.withValues(alpha: 0.1);
              if (roleKey.contains('supermarket') ||
                  roleKey.contains('supérette')) {
                textColor = const Color(0xFF4AA785);
                bgColor = const Color(0xFFDEF8EE);
              } else if (roleKey.contains('gros') ||
                  roleKey.contains('gross') ||
                  roleKey.contains('grosist')) {
                // grosist: text -> #FFFBD4 / background -> #FFC555
                bgColor = const Color(0xFFFFFBD4);
                textColor = const Color(0xFFFFC555);
              } else if (roleKey.contains('admin')) {
                // admin: text -> #EDEDFF / background -> #8A8CD9
                bgColor = const Color(0xFFEDEDFF);
                textColor = const Color(0xFF8A8CD9);
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                    color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  roleKey.contains('supermarket') ||
                          roleKey.contains('supérette')
                      ? AppLanguage.supermarket
                      : roleKey.contains('gros') ||
                              roleKey.contains('gross') ||
                              roleKey.contains('grosist')
                          ? AppLanguage.wholesaler
                          : roleKey.contains('admin')
                              ? AppLanguage.admin
                              : AppLanguage.client,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),

          const SizedBox(width: 4),

          // Actions (view, suspend, delete) - all brandDeep (compact spacing)
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onView,
                  child: Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: AppColors.brandDeep,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onSuspendToggle,
                  child: SvgPicture.asset('assets/icons/suspend.svg',
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                          AppColors.brandDeep, BlendMode.srcIn),
                      semanticsLabel: 'suspend'),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: SvgPicture.asset(
                    'assets/icons/delete.svg',
                    width: 14,
                    height: 14,
                    colorFilter:
                        ColorFilter.mode(AppColors.brandDeep, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
