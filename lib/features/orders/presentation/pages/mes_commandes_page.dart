import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import '../../domain/entities/order.dart';
import '../../../orders/app/bloc/orders_bloc.dart';
import '../../../orders/app/bloc/orders_event.dart';
import '../../../orders/app/bloc/orders_state.dart';
import '../../../../core/config/injection.dart';
import 'order_tracking_page.dart';
import 'user_order_details_page.dart';

import 'package:amerli_app/core/utils/top_toast.dart';

class MesCommandesPage extends StatefulWidget {
  const MesCommandesPage({super.key});

  @override
  State<MesCommandesPage> createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends State<MesCommandesPage> {
  List<String> get tabs => [
        AppLanguage.ordersTabAll,
        AppLanguage.ordersTabInProgress,
        AppLanguage.ordersTabDelivered,
        AppLanguage.ordersTabCanceled,
      ];
  int selected = 0;
  @override
  void initState() {
    super.initState();
    sl<OrdersBloc>().add(OrdersLoadEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Order> _filterForIndex(List<Order> items, int tabIndex) {
    if (tabIndex == 0) {
      return items;
    }
    if (tabIndex == 1) {
      return items
          .where((o) =>
              o.status == OrderStatus.preparing ||
              o.status == OrderStatus.delivering)
          .toList();
    }
    if (tabIndex == 2) {
      return items.where((o) => o.status == OrderStatus.delivered).toList();
    }
    return items.where((o) => o.status == OrderStatus.canceled).toList();
  }

  // Old single-index filter removed; use _filterForIndex instead

  final Color _primary = const Color(0xFFA7C957);
  final Color _dark = const Color(0xFF083B2E);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<OrdersBloc>(),
      child: BlocListener<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrdersError) {
            TopToast.show(context, state.message, isError: true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Center(
                      child: Text(AppLanguage.ordersTitle,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _dark))),
                  const SizedBox(height: 16),

                  // Tabs with sliding indicator and swipe-to-change via PageView
                  LayoutBuilder(builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / tabs.length;
                    return Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Row(
                                children: List.generate(tabs.length, (i) {
                                  final active = i == selected;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() => selected = i);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        alignment: Alignment.center,
                                        child: Text(
                                          tabs[i],
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: active
                                                ? _primary
                                                : const Color(0xFF555555),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              // Sliding indicator
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                left: selected * tabWidth,
                                bottom: 0,
                                width: tabWidth,
                                child: Container(height: 2, color: _primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Content
                  Expanded(
                    child: BlocBuilder<OrdersBloc, OrdersState>(
                        builder: (context, state) {
                      if (state is OrdersLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is OrdersError) {
                        return Center(child: Text(state.message));
                      }
                      // If OrderCreationError, trigger a load to fetch orders
                      if (state is OrderCreationError) {
                        // Trigger load on next frame to avoid build-during-build
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.read<OrdersBloc>().add(OrdersLoadEvent());
                        });
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is OrdersLoaded) {
                        final filtered = _filterForIndex(state.items, selected);
                        if (filtered.isEmpty) {
                          return Center(child: Text(AppLanguage.noOrdersFound));
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<OrdersBloc>().add(OrdersLoadEvent());
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final order = filtered[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserOrderDetailsPage(order: order),
                                    ),
                                  );
                                },
                                child: _OrderCard(
                                  order: order,
                                  onFollow: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderTrackingPage(order: order),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onFollow;

  const _OrderCard({required this.order, required this.onFollow});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivering:
        // En livraison / delivering
        return const Color(0xFF95A4FC);
      case OrderStatus.delivered:
        // Livrée / delivered
        return const Color(0xFFA1E3CB);
      case OrderStatus.preparing:
        // En préparation / preparing
        return const Color(0xFFB1E3FF);
      case OrderStatus.canceled:
        // Annulée / canceled
        return const Color(0xFFF34141);
      case OrderStatus.confirmed:
        // Use delivering color for confirmed (fallback)
        return const Color(0xFF95A4FC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: _statusColor(order.status),
                      shape: BoxShape.circle)),
              const SizedBox(width: 8),
              // Status label uses the same color as the dot
              Text(_labelForStatus(order.status),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(order.status))),
            ],
          ),
          const SizedBox(height: 8),
          // Place the order name before the divider
          Text('${AppLanguage.orderLabel} #${order.id}',
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          Row(
            children: [
              // image placeholder
              Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.image, color: Colors.grey)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${order.productCount} ${AppLanguage.items}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text(
                          'Total : ${order.totalAmount.toStringAsFixed(0)} DZD',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF083B2E))),
                    ]),
              ),
              OutlinedButton(
                onPressed: onFollow,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFA7C957), width: 2.0),
                  shape: const StadiumBorder(),
                  minimumSize: const Size(64, 34),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: Text(AppLanguage.follow,
                    style: const TextStyle(
                        color: Color(0xFF083B2E), fontSize: 14)),
              )
            ],
          )
        ],
      ),
    );
  }

  String _labelForStatus(OrderStatus s) {
    // Use the centralized French display labels
    return s.displayLabel;
  }
}
