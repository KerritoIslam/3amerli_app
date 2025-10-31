import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart';
import '../../../orders/app/bloc/orders_bloc.dart';
import '../../../orders/app/bloc/orders_event.dart';
import '../../../orders/app/bloc/orders_state.dart';
import '../../../../core/config/injection.dart';
import 'order_tracking_page.dart';
import '../../../../core/error/error_handler.dart';

class MesCommandesPage extends StatefulWidget {
  const MesCommandesPage({Key? key}) : super(key: key);

  @override
  State<MesCommandesPage> createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends State<MesCommandesPage> {
  final tabs = const ['Tous', 'En cours', 'Livrées', 'Annulées'];
  int selected = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    sl<OrdersBloc>().add(OrdersLoadEvent());
    _pageController = PageController(initialPage: selected);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Order> _filterForIndex(List<Order> items, int tabIndex) {
    if (tabIndex == 0) return items;
    if (tabIndex == 1) return items.where((o) => o.status == OrderStatus.preparing || o.status == OrderStatus.delivering).toList();
    if (tabIndex == 2) return items.where((o) => o.status == OrderStatus.delivered).toList();
    return items.where((o) => o.status == OrderStatus.canceled).toList();
  }

  // Old single-index filter removed; use _filterForIndex instead

  Color _primary = const Color(0xFFA7C957);
  Color _dark = const Color(0xFF083B2E);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<OrdersBloc>(),
      child: BlocListener<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrdersError) {
            ErrorHandler.showError(context, state.message);
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
                Center(child: Text('Mes Commandes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _dark))),
                const SizedBox(height: 16),

                // Tabs with sliding indicator and swipe-to-change via PageView
                LayoutBuilder(builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / tabs.length;
                  return Column(
                    children: [
                      Stack(
                        children: [
                          Row(
                            children: List.generate(tabs.length, (i) {
                              final active = i == selected;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                    setState(() => selected = i);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    alignment: Alignment.center,
                                    child: Text(tabs[i], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: active ? _primary : const Color(0xFF555555))),
                                  ),
                                ),
                              );
                            }),
                          ),
                          // Sliding indicator
                          AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              final page = (_pageController.hasClients && _pageController.page != null) ? _pageController.page! : selected.toDouble();
                              final left = page * tabWidth;
                              return Positioned(
                                left: left,
                                bottom: 0,
                                width: tabWidth,
                                child: Container(height: 2, color: _primary),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 12),

                // Content
                Expanded(
                  child: BlocBuilder<OrdersBloc, OrdersState>(builder: (context, state) {
                    if (state is OrdersLoading) return const Center(child: CircularProgressIndicator());
                    if (state is OrdersError) {
                      // Error handled by BlocListener
                      return const Center(child: Text('Aucune commande trouvée'));
                    }

                    // Use PageView so users can swipe between tabs
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: tabs.length,
                      onPageChanged: (idx) => setState(() => selected = idx),
                      itemBuilder: (context, pageIndex) {
                        final items = state is OrdersLoaded ? _filterForIndex(state.items, pageIndex) : const <Order>[];
                        return RefreshIndicator(
                          onRefresh: () async {
                            sl<OrdersBloc>().add(OrdersLoadEvent());
                            await sl<OrdersBloc>().stream.firstWhere((s) => s is! OrdersLoading);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final o = items[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _OrderCard(order: o, onFollow: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderTrackingPage(order: o)))),
                              );
                            },
                          ),
                        );
                      },
                    );
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

  const _OrderCard({Key? key, required this.order, required this.onFollow}) : super(key: key);

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
    final total = order.products.fold<double>(0, (p, e) => p + e.price * e.quantity);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _statusColor(order.status), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              // Status label uses the same color as the dot
              Text(_labelForStatus(order.status), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _statusColor(order.status))),
            ],
          ),
          const SizedBox(height: 8),
          // Place the order name before the divider
          Text('Commande #${order.id}', style: const TextStyle(fontSize: 14, color: Color(0xFF555555), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          Row(
            children: [
              // image placeholder
              Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${order.products.length} Articles', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text('Total : ${total.toStringAsFixed(0)} DZD', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF083B2E))),
                ]),
              ),
              OutlinedButton(
                onPressed: onFollow,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFA7C957), width: 2.0),
                  shape: const StadiumBorder(),
                  minimumSize: const Size(64, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: const Text('Suivre', style: TextStyle(color: Color(0xFF083B2E), fontSize: 14)),
              )
            ],
          )
        ],
      ),
    );
  }

  String _labelForStatus(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed:
        return 'Commande confirmée';
      case OrderStatus.canceled:
        return 'Annulée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.delivering:
        return 'En cours de livraison';
      case OrderStatus.delivered:
        return 'Livrée';
    }
  }
}
