import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../widgets/product_tile.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: SafeArea(
        child: BlocBuilder<CatalogBloc, CatalogState>(
          builder: (context, state) {
            if (state is CatalogLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CatalogLoaded) {
              final products = state.products;
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => ProductTile(product: products[index]),
              );
            } else if (state is CatalogError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Center(child: ElevatedButton(onPressed: () => context.read<CatalogBloc>().add(CatalogLoadEvent()), child: const Text('Load')));
          },
        ),
      ),
    );
  }
}
