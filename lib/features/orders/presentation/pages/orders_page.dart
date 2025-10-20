import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_cubit.dart';
import '../widgets/order_tile.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: BlocBuilder<OrdersCubit, OrdersState>(builder: (context, state) {
        if (state.loading) return const Center(child: CircularProgressIndicator());
        if (state.error != null) return Center(child: Text('Erreur: ${state.error}'));

        final grouped = <String, List<Order>>{};
        for (var o in state.orders) {
          final key = o.status.nameValue;
          grouped.putIfAbsent(key, () => []).add(o);
        }

        if (state.orders.isEmpty) return const Center(child: Text('Aucune commande'));

        return ListView(
          padding: const EdgeInsets.all(12.0),
          children: grouped.entries.map((e) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(e.key, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ...e.value.map((o) => OrderTile(order: o)).toList(),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        );
      }),
    );
  }
}
