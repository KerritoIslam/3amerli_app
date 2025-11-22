import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../utils/constants/app_colors.dart';
import '../../domain/entities/admin_user.dart';
import '../bloc/admin_users_bloc.dart';
import '../bloc/admin_users_event.dart';
import '../bloc/admin_users_state.dart';

import 'package:amerli_app/core/utils/top_toast.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
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

  Color _getActiveStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }

  String _getActiveStatusText(bool isActive) {
    // TODO: Use app localization
    return isActive ? 'Actif' : 'Suspendu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AdminUsersBloc, AdminUsersState>(
        listener: (context, state) {
          if (state is AdminUsersOperationSuccess) {
            TopToast.show(context, state.message, isError: false);
            // Reload user details after successful operation
            context.read<AdminUsersBloc>().add(
                  AdminUsersLoadDetailEvent(userId: widget.userId),
                );
          } else if (state is AdminUsersError) {
            TopToast.show(context, state.message, isError: true);
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
                          color: _getActiveStatusColor(user.isActive)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getActiveStatusColor(user.isActive),
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
                                color: _getActiveStatusColor(user.isActive),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getActiveStatusText(user.isActive),
                              style: TextStyle(
                                color: _getActiveStatusColor(user.isActive),
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
                  if (user.supermarketName != null)
                    _InfoRow(label: 'Supérette', value: user.supermarketName!),
                  _InfoRow(label: 'Téléphone', value: user.phone),
                  if (user.storeName != null)
                    _InfoRow(label: 'Magasin', value: user.storeName!),
                  if (user.representativeName != null)
                    _InfoRow(
                      label: 'Représentant',
                      value: user.representativeName!,
                    ),
                ]),

                const SizedBox(height: 24),

                // Addresses Section
                if (user.addresses != null && user.addresses!.isNotEmpty) ...[
                  _buildSectionTitle('Adresses'),
                  const SizedBox(height: 16),
                  ...user.addresses!.map((address) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildInfoCard([
                          _InfoRow(label: 'Rue', value: address.street),
                          _InfoRow(label: 'Ville', value: address.city),
                          _InfoRow(label: 'Quartier', value: address.district),
                        ]),
                      )),
                  const SizedBox(height: 12),
                ],

                // Role Section (Read-only)
                _buildSectionTitle('Rôle'),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _InfoRow(label: 'Rôle', value: user.role),
                ]),

                const SizedBox(height: 24),

                // Status Section with Text Button
                _buildSectionTitle('Statut du compte'),
                const SizedBox(height: 16),
                _buildStatusCardWithButton(user),

                const SizedBox(height: 24),

                // Activity History (without last active date)
                _buildSectionTitle('Historique'),
                const SizedBox(height: 16),
                _buildInfoCard([
                  _InfoRow(
                    label: 'Date d\'inscription',
                    value: _formatDate(user.registrationDate),
                  ),
                ]),

                // Add bottom padding to avoid navigation bar covering content
                const SizedBox(height: 100),
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

  Widget _buildStatusCardWithButton(AdminUser user) {
    final isActive = user.isActive;
    final buttonText = isActive ? 'Suspendre' : 'Activer';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getActiveStatusColor(user.isActive),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getActiveStatusText(user.isActive),
                style: TextStyle(
                  color: _getActiveStatusColor(user.isActive),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: Text(
                    'Êtes-vous sûr de vouloir ${buttonText.toLowerCase()} cet utilisateur?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Use blacklist endpoints for suspend/activate
                        if (isActive) {
                          // Suspend user by adding to blacklist
                          this.context.read<AdminUsersBloc>().add(
                                AdminUsersAddToBlacklistEvent(userId: user.id),
                              );
                        } else {
                          // Activate user by restoring from blacklist
                          this.context.read<AdminUsersBloc>().add(
                                AdminUsersRestoreFromBlacklistEvent(
                                    userId: user.id),
                              );
                        }
                      },
                      child: Text(buttonText),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: isActive ? Colors.red : Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
