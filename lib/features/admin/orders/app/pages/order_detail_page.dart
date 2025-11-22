import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_orders_bloc.dart';
import '../bloc/admin_orders_event.dart';
import '../bloc/admin_orders_state.dart';
import '../../domain/entities/admin_order.dart';
import 'package:amerli_app/core/error/error_handler.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

import 'package:amerli_app/core/utils/top_toast.dart';

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
  @override
  void initState() {
    super.initState();
    context
        .read<AdminOrdersBloc>()
        .add(AdminOrdersLoadDetailEvent(widget.orderId));
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('en attente') ||
        s.contains('pending') ||
        s.contains('confirmation') ||
        s.contains('confirm')) {
      return const Color(0xFFFFC555);
    }
    if (s.contains('préparation') ||
        s.contains('preparation') ||
        s.contains('preparing')) {
      return const Color(0xFF59A8D4);
    }
    if (s.contains('livré') ||
        s.contains('livree') ||
        s.contains('deliv') ||
        s.contains('delivered')) {
      return const Color(0xFF4AA785);
    }
    if (s.contains('annul') || s.contains('canceled') || s.contains('cancel')) {
      return const Color(0xFFF34141);
    }
    return Colors.grey;
  }

  void _onIncrementStatus(AdminOrder order) {
    context.read<AdminOrdersBloc>().add(
          AdminOrdersIncrementStatusEvent(order.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) =>
          BlocListener<AdminOrdersBloc, AdminOrdersState>(
        listener: (context, state) {
          if (state is AdminOrdersError) {
            ErrorHandler.showError(context, state.message);
          }
          if (state is AdminOrderDetailLoaded) {
            if (state.message != null) {
              TopToast.show(context, state.message!, isError: false);
            }
            if (state.errorMessage != null) {
              TopToast.show(context, state.errorMessage!, isError: true);
            }
          }
          if (state is AdminOrdersOperationSuccess) {
            TopToast.show(context, state.message, isError: false);
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
                            Expanded(
                              child: Text(
                                AppLanguage.orderDetails,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(
                                width: 40), // Balance the back button
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
                                Text(
                                  AppLanguage.orderedItems,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...order.products.map(
                                    (product) => _ProductRow(product: product)),
                                const SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${AppLanguage.total} :',
                                        style: const TextStyle(
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
                              Text(
                                AppLanguage.clientInfo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _InfoRow(
                                label: AppLanguage.storeName,
                                value: order.storeName,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: AppLanguage.representativeName,
                                value: order.representativeName,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: AppLanguage.phone,
                                value: order.customerPhone,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: AppLanguage.fullAddress,
                                value: order.deliveryAddress ?? 'N/A',
                              ),
                              const SizedBox(height: 24),

                              // Informations du paiement
                              Text(
                                AppLanguage.paymentInfo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _InfoRow(
                                label: AppLanguage.paymentInfo,
                                value: order.paymentMethod,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: AppLanguage.total,
                                value:
                                    '${order.totalAmount.toStringAsFixed(2)} DZD',
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: AppLanguage.dateTime,
                                value:
                                    '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}  ${order.orderDate.hour.toString().padLeft(2, '0')}:${order.orderDate.minute.toString().padLeft(2, '0')}',
                              ),
                              const SizedBox(height: 24),

                              // Statut actuel
                              Text(
                                AppLanguage.currentStatus,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Status display and increment button
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: _getStatusColor(order.status),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (state.isIncrementing)
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    )
                                  else if (!order.status
                                          .toLowerCase()
                                          .contains('livré') &&
                                      !order.status
                                          .toLowerCase()
                                          .contains('delivered'))
                                    InkWell(
                                      onTap: () => _onIncrementStatus(order),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              AppLanguage.nextStep,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ],
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

                return Center(child: Text(AppLanguage.orderNotFound));
              },
            ),
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
                '${AppLanguage.quantityAbbr}: ${product.quantity}',
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
