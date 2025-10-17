import 'package:amerli_app/features/cart/app/widgets/products_tiles_list.dart';
import 'package:amerli_app/widgets/bottom_cart_summary.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_event.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_state.dart';
import 'package:amerli_app/core/config/injection.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide CartBloc if not already available in the tree
        BlocProvider<CartBloc>.value(value: sl<CartBloc>()),
      ],
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 28, right: 28),
        child: BlocBuilder<CartBloc, CartState>(builder: (context, cartState) {
          final cartItems = cartState is CartLoaded ? cartState.items : const [];

          return BlocBuilder<CatalogBloc, CatalogState>(builder: (context, catalogState) {
            List<Product> sourceProducts = [];
            if (catalogState is CatalogLoaded || catalogState is CatalogLoadingMore) {
              sourceProducts = (catalogState as dynamic).products as List<Product>;
            }

            // Build products list with quantity > 0 based on cart items joined with catalog products
            final productsInCart = cartItems.map((ci) {
              final id = int.tryParse(ci.productId) ?? -1;
              final p = sourceProducts.firstWhere(
                (sp) => sp.id == id,
                orElse: () => Product(
                  id: id,
                  name: ci.name,
                  description: '',
                  price: ci.price,
                  stock: 0,
                  pic: ci.imageUrl,
                ),
              );
              return Product(
                id: p.id,
                name: p.name,
                description: p.description,
                price: p.price,
                stock: p.stock,
                sellerId: p.sellerId,
                pic: p.pic,
                markId: p.markId,
                isFavorit: p.isFavorit,
                quantity: ci.quantity,
              );
            }).where((p) => p.quantity > 0).toList();

            if (productsInCart.isEmpty) {
              return const Center(child: Text('Votre panier est vide'));
            }

            // compute total
            final total = productsInCart.fold<double>(0.0, (sum, p) => sum + (p.price * p.quantity));

            return Stack(
              children: [
                // Product list - give bottom padding so last items aren't hidden under the summary
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + 120),
                    child: ProductsTilesList(
                      products: productsInCart,
                      onQuantityChange: (index, quantity) {
                        final product = productsInCart[index];
                        final productIdStr = product.id.toString();
                        if (quantity <= 0) {
                          context.read<CartBloc>().add(CartUpdateQuantityEvent(productId: productIdStr, quantity: 0));
                        } else {
                          context.read<CartBloc>().add(CartUpdateQuantityEvent(productId: productIdStr, quantity: quantity));
                        }
                      },
                    ),
                  ),
                ),

                // Bottom summary positioned above bottom nav bar so it doesn't block nav
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: kBottomNavigationBarHeight + 64,
                  child: Center(
                    child: BottomCartSummary(
                      total: total,
                      onPay: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paiement non implémenté — total: ${total.toStringAsFixed(0)} DZD')));
                      },
                    ),
                  ),
                ),
              ],
            );
          });
        }),
      ),
    );
  }
}
