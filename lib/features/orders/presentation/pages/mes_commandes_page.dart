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
  final ScrollController _scrollController = ScrollController();
  final Color _primary = const Color(0xFFA7C957);
  final Color _dark = const Color(0xFF083B2E);
  late OrdersBloc _ordersBloc;

  @override
  void initState() {
    super.initState();
    _ordersBloc = sl<OrdersBloc>();
    _loadOrders();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = _ordersBloc.state;
      if (state is OrdersLoaded && state.hasNextPage) {
        final currentCount = state.items.length;
        final nextPage = (currentCount / 20).ceil() + 1;

        _ordersBloc.add(OrdersLoadEvent(
          page: nextPage,
          status: _getStatusForTab(selected),
        ));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _loadOrders() {
    _ordersBloc.add(OrdersLoadEvent(
      page: 1,
      status: _getStatusForTab(selected),
    ));
  }

  String? _getStatusForTab(int index) {
    switch (index) {
      case 0:
        return null; // All
      case 1:
        return 'IN_PROGRESS'; // In Progress
      case 2:
        return 'DELIVERED';
      case 3:
        return 'CANCELED';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ordersBloc,
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

                  // Tabs
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
                                        _loadOrders();
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
                      if (state is OrderCreationError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _loadOrders();
                        });
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is OrdersLoaded) {
                        if (state.items.isEmpty) {
                          return Center(child: Text(AppLanguage.noOrdersFound));
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            _loadOrders();
                          },
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: state.items.length +
                                (state.hasNextPage ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              if (index >= state.items.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final order = state.items[index];
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
                                            BlocProvider.value(
                                          value: _ordersBloc,
                                          child:
                                              OrderTrackingPage(order: order),
                                        ),
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
              color: Colors.black.withOpacity(0.05),
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
              // image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  image: (order.products.isNotEmpty &&
                          order.products.first.imageUrl != null &&
                          order.products.first.imageUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(order.products.first.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (order.products.isEmpty ||
                        order.products.first.imageUrl == null ||
                        order.products.first.imageUrl!.isEmpty)
                    ? const Icon(Icons.image, color: Colors.grey)
                    : null,
              ),
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
