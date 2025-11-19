import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_orders_bloc.dart';
import '../bloc/admin_orders_event.dart';
import '../bloc/admin_orders_state.dart';
import '../../domain/entities/admin_order.dart';
import 'package:amerli_app/core/error/error_handler.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  String? _selectedStatus;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<AdminOrdersBloc>().add(AdminOrdersLoadDetailEvent(widget.orderId));
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

  void _onStatusChanged(String newStatus, AdminOrder order) {
    setState(() {
      _selectedStatus = newStatus;
    });
  }

  void _onSaveStatus(AdminOrder order) {
    if (_selectedStatus != null && _selectedStatus != order.status) {
      context.read<AdminOrdersBloc>().add(
            AdminOrdersUpdateStatusEvent(order.id, _selectedStatus!),
          );
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminOrdersBloc, AdminOrdersState>(
      listener: (context, state) {
        if (state is AdminOrdersError) {
          ErrorHandler.showError(context, state.message);
        }
        if (state is AdminOrdersOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<AdminOrdersBloc, AdminOrdersState>(
            builder: (context, state) {
              if (state is AdminOrderDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AdminOrderDetailLoaded) {
                final order = state.order;
                _selectedStatus ??= order.status;

                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Détails',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40), // Balance the back button
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Articles commandés
                            if (order.products.isNotEmpty) ...[
                              const Text(
                                'Articles commandés',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...order.products.map((product) => _ProductRow(product: product)),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total :',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${order.totalAmount.toStringAsFixed(2)} DZD',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Informations du client
                            const Text(
                              'Informations du client',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              label: 'Nom de la supérette',
                              value: order.storeName,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: 'Nom et prénom du réprésentant',
                              value: order.representativeName,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: 'Numéro de téléphone',
                              value: order.customerPhone,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: 'Adresse complète',
                              value: order.deliveryAddress ?? 'N/A',
                            ),
                            const SizedBox(height: 24),

                            // Informations du paiement
                            const Text(
                              'Informations du paiement',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              label: 'Mode de paiement',
                              value: order.paymentMethod,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: 'Montant',
                              value: '${order.totalAmount.toStringAsFixed(2)} DZD',
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: 'Date et heure',
                              value: '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}  ${order.orderDate.hour.toString().padLeft(2, '0')}:${order.orderDate.minute.toString().padLeft(2, '0')}',
                            ),
                            const SizedBox(height: 24),

                            // Statut actuel
                            const Text(
                              'Statut actuel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Status selector with edit icon
                            Row(
                              children: [
                                Expanded(
                                  child: _isEditing
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _selectedStatus,
                                              isExpanded: true,
                                              icon: const Icon(Icons.keyboard_arrow_down),
                                              items: [
                                                'En attente',
                                                'En Préparation',
                                                'En cours',
                                                'Livrée',
                                                'Annulée',
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  _onStatusChanged(newValue, order);
                                                }
                                              },
                                            ),
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(_selectedStatus!).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _selectedStatus!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: _getStatusColor(_selectedStatus!),
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                if (!_isEditing)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isEditing = true;
                                      });
                                    },
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                if (_isEditing)
                                  InkWell(
                                    onTap: () => _onSaveStatus(order),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const Center(child: Text('Commande non trouvée'));
            },
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final OrderProduct product;

  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade400,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${product.id}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Quantity and Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Qté: ${product.quantity}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.pricePerUnit.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.total.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
