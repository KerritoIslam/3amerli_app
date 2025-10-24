import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart';
import '../../../orders/app/bloc/orders_bloc.dart';
import '../../../orders/app/bloc/orders_event.dart';
import '../../../orders/app/bloc/orders_state.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../data/datasources/mock_orders_remote_datasource.dart';
import 'order_tracking_page.dart';

class MesCommandesPage extends StatefulWidget {
  const MesCommandesPage({Key? key}) : super(key: key);

  @override
  State<MesCommandesPage> createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends State<MesCommandesPage> {
  final tabs = const ['Tous', 'En cours', 'Livrées', 'Annulées'];
  int selected = 0;

  late final OrdersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = OrdersBloc(repository: OrdersRepositoryImpl(remote: MockOrdersRemoteDataSource()));
    _bloc.add(OrdersLoadEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  List<Order> _filter(List<Order> items) {
    if (selected == 0) return items;
    if (selected == 1) return items.where((o) => o.status == OrderStatus.preparing || o.status == OrderStatus.delivering).toList();
    if (selected == 2) return items.where((o) => o.status == OrderStatus.delivered).toList();
    // Annulées
    return items.where((o) => o.status == OrderStatus.canceled).toList();
  }

  Color _primary = const Color(0xFFA7C957);
  Color _dark = const Color(0xFF083B2E);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
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

                // Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(tabs.length, (i) {
                    final active = i == selected;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selected = i),
                        child: Column(
                          children: [
                            // Animate the text color when switching tabs
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: active ? _primary : const Color(0xFF555555)),
                              child: Text(tabs[i]),
                            ),
                            const SizedBox(height: 6),
                            // Smooth underline indicator transition
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              height: 2,
                              color: active ? _primary : Colors.transparent,
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 12),

                // Content
                Expanded(
                  child: BlocBuilder<OrdersBloc, OrdersState>(builder: (context, state) {
                    if (state is OrdersLoading) return const Center(child: CircularProgressIndicator());
                    if (state is OrdersError) return Center(child: Text('Erreur: ${state.message}'));

                    final items = state is OrdersLoaded ? _filter(state.items) : const <Order>[];

                    return RefreshIndicator(
                      onRefresh: () async {
                        _bloc.add(OrdersLoadEvent());
                        // wait until loaded
                        await _bloc.stream.firstWhere((s) => s is! OrdersLoading);
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
                  }),
                )
              ],
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
