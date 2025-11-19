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
    final s = status.toLowerCase();
    // handle multiple languages and uppercase codes from backend
    if (s.contains('en attente') || s.contains('pending') || s.contains('confirmation') || s.contains('confirm')) {
      return const Color(0xFFFFC555);
    }
    if (s.contains('préparation') || s.contains('preparation') || s.contains('preparing')) {
      return const Color(0xFF59A8D4);
    }
    if (s.contains('livré') || s.contains('livree') || s.contains('deliv') || s.contains('delivered')) {
      return const Color(0xFF4AA785);
    }
    if (s.contains('annul') || s.contains('canceled') || s.contains('cancel')) {
      return const Color(0xFFF34141);
    }

    return Colors.grey;
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
                          margin: const EdgeInsets.symmetric(horizontal: 10),
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
                                horizontal: 6,
                                vertical: 6,
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
                                    width: 18,
                                    height: 18,
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
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 80,
                                    child: const Text(
                                      'N° Commande',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Client',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Statut',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 40,
                                    child: Text(
                                      'Actions',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.start,
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
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: isSelected,
              onChanged: onSelectChanged,
              shape: const CircleBorder(),
              activeColor: AppColors.brandDeep,
            ),
          ),
          const SizedBox(width: 6),

          // Order Number
          SizedBox(
            width: 80,
            child: Text(
              order.orderNumber,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Client Name
          Expanded(
            flex: 2,
            child: SizedBox(
              width: 70,
              child: Text(
                order.customerName,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Status
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 10,
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
            width: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // View Button
                InkWell(
                  onTap: onView,
                  child: Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: AppColors.brandDeep,
                    ),
                ),
                const SizedBox(width: 4),
                // Cancel Button
                InkWell(
                  onTap: onCancel,
                  child: const Icon(
                    Icons.close,
                    size: 14,
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
