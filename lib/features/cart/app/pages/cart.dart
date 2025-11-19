import 'package:amerli_app/features/cart/app/widgets/products_tiles_list.dart';
import 'package:amerli_app/widgets/bottom_cart_summary.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_event.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'package:amerli_app/features/cart/app/pages/paiement_screen.dart';
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
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) {
        return Scaffold(
          appBar: AppBar(title: Center(child:  Text(AppLanguage.myCart,style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiaryContainer,
          )),)),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 28, right: 28),
        child: BlocBuilder<CartBloc, CartState>(builder: (context, cartState) {
          // debug
          // ignore: avoid_print
          print('CartPage rebuild - cartState: ${cartState.runtimeType}');
          final cartItems = cartState is CartLoaded ? cartState.items : const [];
          // ignore: avoid_print
          print('CartPage - cartItems count: ${cartItems.length}');

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
                  pics: ci.imageUrl != null && ci.imageUrl!.isNotEmpty ? [ci.imageUrl!] : const [],
                  brand: ci.brand,
                  soldBy: ci.soldBy,
                ),
              );
              return Product(
                id: p.id,
                name: p.name,
                description: p.description,
                price: p.price,
                stock: p.stock,
                sellerId: p.sellerId,
                soldBy: p.soldBy,
                pics: p.pics,
                brand: p.brand,
                markId: p.markId,
                isFavorit: p.isFavorit,
                quantity: ci.quantity,
              );
            }).where((p) => p.quantity > 0).toList();

            if (productsInCart.isEmpty) {
              return Center(child: Text(AppLanguage.emptyCart));
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
                          // Replace the current cart page in the nested navigator with the PaiementScreen
                          // Wrap the new route with the existing CartBloc so the payment screen can access it
                          final cartBloc = context.read<CartBloc>();
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => BlocProvider.value(value: cartBloc, child: const PaiementScreen())));
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
      },
    );
  }
}
