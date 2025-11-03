import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_orders_bloc.dart';
import '../bloc/admin_orders_event.dart';
import '../bloc/admin_orders_state.dart';
import '../../domain/entities/admin_order.dart';
import 'package:amerli_app/core/error/error_handler.dart';
import 'package:amerli_app/widgets/searchbar.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedOrderIds = {};

  @override
  void initState() {
    super.initState();
    context.read<AdminOrdersBloc>().add(AdminOrdersLoadEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<AdminOrdersBloc>().add(AdminOrdersLoadEvent(query: query.isEmpty ? null : query));
  }

  void _onExportCSV() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export CSV fonctionnalité à venir')),
    );
  }

  void _onDeleteSelected() {
    if (_selectedOrderIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer les commandes'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer ${_selectedOrderIds.length} commande(s) ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete multiple orders
              setState(() {
                _selectedOrderIds.clear();
              });
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en attente':
        return Colors.orange;
      case 'en cours':
      case 'en préparation':
        return Colors.blue;
      case 'livrée':
      case 'livré':
        return Colors.green;
      case 'annulée':
      case 'annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminOrdersBloc, AdminOrdersState>(
      listener: (context, state) {
        if (state is AdminOrdersError) {
          ErrorHandler.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Commandes',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Search and Export Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Search Field
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: AppSearchbar(
                          onChanged: _onSearch,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Export Button
                    ElevatedButton(
                      onPressed: _onExportCSV,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Exporter CVS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Delete Selected Button (visible when items are selected)
              if (_selectedOrderIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        '${_selectedOrderIds.length} sélectionné(s)',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _onDeleteSelected,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Orders Table
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<AdminOrdersBloc, AdminOrdersState>(
                    builder: (context, state) {
                      if (state is AdminOrdersLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is AdminOrdersLoaded) {
                        if (state.orders.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune commande trouvée',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Select All Checkbox
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _selectedOrderIds.length ==
                                          state.orders.length,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedOrderIds.addAll(
                                              state.orders.map((o) => o.id),
                                            );
                                          } else {
                                            _selectedOrderIds.clear();
                                          }
                                        });
                                      },
                                      shape: const CircleBorder(),
                                      activeColor: AppColors.brandDeep,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      'N° Commande',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Client',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Statut',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 50,
                                    child: Text(
                                      'Actions',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Orders List
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.orders.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Colors.grey.shade200,
                                ),
                                itemBuilder: (context, index) {
                                  final order = state.orders[index];
                                  final isSelected = _selectedOrderIds.contains(order.id);
                                  
                                  return _OrderRow(
                                    order: order,
                                    isSelected: isSelected,
                                    statusColor: _getStatusColor(order.status),
                                    onSelectChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedOrderIds.add(order.id);
                                        } else {
                                          _selectedOrderIds.remove(order.id);
                                        }
                                      });
                                    },
                                    onView: () {
                                      context.push('/admin/orders/${order.id}');
                                    },
                                    onCancel: () {
                                      // TODO: Implement cancel order
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final AdminOrder order;
  final bool isSelected;
  final Color statusColor;
  final ValueChanged<bool?> onSelectChanged;
  final VoidCallback onView;
  final VoidCallback onCancel;

  const _OrderRow({
    required this.order,
    required this.isSelected,
    required this.statusColor,
    required this.onSelectChanged,
    required this.onView,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: onSelectChanged,
              shape: const CircleBorder(),
              activeColor: AppColors.brandDeep,
            ),
          ),
          const SizedBox(width: 12),

          // Order Number
          Expanded(
            flex: 3,
            child: Text(
              order.orderNumber,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Client Name
          Expanded(
            flex: 3,
            child: Text(
              order.customerName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          SizedBox(
            width: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // View Button
                InkWell(
                  onTap: onView,
                  child: Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                // Cancel Button
                InkWell(
                  onTap: onCancel,
                  child: const Icon(
                    Icons.close,
                    size: 18,
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
