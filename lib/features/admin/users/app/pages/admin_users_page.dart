import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../utils/constants/app_colors.dart';
import '../../../../../widgets/searchbar.dart';
import '../../domain/entities/admin_user.dart';
import '../bloc/admin_users_bloc.dart';
import '../bloc/admin_users_event.dart';
import '../bloc/admin_users_state.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _selectedTab = 'Tous';
  String _searchQuery = '';
  final Set<String> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    final statusFilter = _selectedTab == 'Suspendu' ? 'Suspendu' : null;
    context.read<AdminUsersBloc>().add(AdminUsersLoadEvent(
          query: _searchQuery.isEmpty ? null : _searchQuery,
          statusFilter: statusFilter,
        ));
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

  void _onDeleteSelected() {
    if (_selectedUserIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Voulez-vous vraiment supprimer ${_selectedUserIds.length} utilisateur(s) ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
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
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Utilisateurs',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (_selectedUserIds.isNotEmpty) ...[
                      ElevatedButton(
                        onPressed: _onDeleteSelected,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Supprimer (${_selectedUserIds.length})',
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement export to CSV
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Exporter CVS'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppSearchbar(
              onChanged: _onSearchChanged,
            ),
          ),

          const SizedBox(height: 16),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _TabButton(
                  label: 'Tous',
                  isSelected: _selectedTab == 'Tous',
                  onTap: () => _onTabChanged('Tous'),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: 'Suspendu',
                  isSelected: _selectedTab == 'Suspendu',
                  onTap: () => _onTabChanged('Suspendu'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Users Table
          Expanded(
            child: SingleChildScrollView(
              child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
                builder: (context, state) {
                  if (state is AdminUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AdminUsersLoaded) {
                    return _buildUsersTable(state.users);
                  } else if (state is AdminUsersError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(List<AdminUser> users) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
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
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      value: _selectedUserIds.length == users.length && users.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUserIds.addAll(users.map((u) => u.id));
                          } else {
                            _selectedUserIds.clear();
                          }
                        });
                      },
                      shape: const CircleBorder(),
                      activeColor: AppColors.brandDeep,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Nom',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Tél',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Rôle',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const SizedBox(
                    width: 40,
                    child: Text(
                      'Action',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // Table Body
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _UserRow(
                    user: users[index],
                    isSelected: _selectedUserIds.contains(users[index].id),
                    onSelectionChanged: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedUserIds.add(users[index].id);
                        } else {
                          _selectedUserIds.remove(users[index].id);
                        }
                      });
                    },
                    onView: () {
                      context.push('/admin/users/${users[index].id}');
                    },
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: Text(
                              'Voulez-vous vraiment supprimer ${users[index].name} ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<AdminUsersBloc>().add(
                                        AdminUsersDeleteEvent(
                                          userId: users[index].id,
                                        ),
                                      );
                                  Navigator.of(dialogContext).pop();
                                  _loadUsers();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  const _UserRow({
    required this.user,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                fontSize: 12,
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
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 4),

          // Role Badge
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.role,
                style: TextStyle(
                  color: AppColors.lightPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Actions
          SizedBox(
            width: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onView,
                  child: Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: AppColors.lightPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.red,
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
