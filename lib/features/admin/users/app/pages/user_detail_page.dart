import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../utils/constants/app_colors.dart';
import '../../domain/entities/admin_user.dart';
import '../bloc/admin_users_bloc.dart';
import '../bloc/admin_users_event.dart';
import '../bloc/admin_users_state.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool _isEditingRole = false;
  bool _isEditingStatus = false;
  String? _selectedRole;
  String? _selectedStatus;

  final List<String> _availableRoles = [
    'Admin',
    'Supérette',
    'Grossiste',
    'Livreur',
  ];

  final List<String> _availableStatuses = [
    'Actif',
    'Suspendu',
  ];

  @override
  void initState() {
    super.initState();
    context.read<AdminUsersBloc>().add(
          AdminUsersLoadDetailEvent(userId: widget.userId),
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    return status == 'Actif' ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AdminUsersBloc, AdminUsersState>(
        listener: (context, state) {
          if (state is AdminUsersOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _isEditingRole = false;
              _isEditingStatus = false;
            });
          } else if (state is AdminUsersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminUserDetailLoaded) {
              return _buildDetailView(state.user);
            } else if (state is AdminUsersError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetailView(AdminUser user) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              const Text(
                'Fiche utilisateur',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and Status
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.lightPrimary.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppColors.lightPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 48,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(user.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor(user.status),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(user.status),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.status,
                              style: TextStyle(
                                color: _getStatusColor(user.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // User Information
                _buildSectionTitle('Informations de l\'utilisateur'),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _InfoRow(label: 'Nom', value: user.name),
                  _InfoRow(label: 'Email', value: user.email),
                  _InfoRow(label: 'Téléphone', value: user.phone),
                  if (user.storeName != null)
                    _InfoRow(label: 'Magasin', value: user.storeName!),
                  if (user.representativeName != null)
                    _InfoRow(
                      label: 'Représentant',
                      value: user.representativeName!,
                    ),
                  if (user.address != null)
                    _InfoRow(label: 'Adresse', value: user.address!),
                ]),

                const SizedBox(height: 24),

                // Role Section
                _buildSectionTitle('Rôle'),
                const SizedBox(height: 16),
                _buildRoleCard(user),

                const SizedBox(height: 24),

                // Status Section
                _buildSectionTitle('Statut du compte'),
                const SizedBox(height: 16),
                _buildStatusCard(user),

                const SizedBox(height: 24),

                // Activity History
                _buildSectionTitle('Historique'),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _InfoRow(
                    label: 'Date d\'inscription',
                    value: _formatDate(user.registrationDate),
                  ),
                  _InfoRow(
                    label: 'Dernière activité',
                    value: _formatDateTime(user.lastActivityDate),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows
            .map((row) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: row != rows.last
                          ? BorderSide(color: Colors.grey[300]!, width: 1)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          row.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.value,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRoleCard(AdminUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 150,
            child: Text(
              'Rôle actuel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: _isEditingRole
                ? Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedRole ?? user.role,
                          isExpanded: true,
                          items: _availableRoles
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          if (_selectedRole != null &&
                              _selectedRole != user.role) {
                            context.read<AdminUsersBloc>().add(
                                  AdminUsersUpdateRoleEvent(
                                    userId: user.id,
                                    newRole: _selectedRole!,
                                  ),
                                );
                          } else {
                            setState(() {
                              _isEditingRole = false;
                            });
                          }
                        },
                        icon: const Icon(Icons.check, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditingRole = false;
                            _selectedRole = null;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role,
                          style: TextStyle(
                            color: AppColors.lightPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditingRole = true;
                            _selectedRole = user.role;
                          });
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppColors.lightPrimary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AdminUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 150,
            child: Text(
              'Statut',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: _isEditingStatus
                ? Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedStatus ?? user.status,
                          isExpanded: true,
                          items: _availableStatuses
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          if (_selectedStatus != null &&
                              _selectedStatus != user.status) {
                            context.read<AdminUsersBloc>().add(
                                  AdminUsersUpdateStatusEvent(
                                    userId: user.id,
                                    newStatus: _selectedStatus!,
                                  ),
                                );
                          } else {
                            setState(() {
                              _isEditingStatus = false;
                            });
                          }
                        },
                        icon: const Icon(Icons.check, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditingStatus = false;
                            _selectedStatus = null;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(user.status),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.status,
                            style: TextStyle(
                              color: _getStatusColor(user.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditingStatus = true;
                            _selectedStatus = user.status;
                          });
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppColors.lightPrimary,
                          size: 20,
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

class _InfoRow {
  final String label;
  final String value;

  _InfoRow({required this.label, required this.value});
}
