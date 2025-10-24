import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_state.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/features/success/app/pages/success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/widgets/bottom_cart_summary.dart';

class PaiementScreen extends StatefulWidget {
  const PaiementScreen({Key? key}) : super(key: key);

  @override
  State<PaiementScreen> createState() => _PaiementScreenState();
}

class _PaiementScreenState extends State<PaiementScreen> {
  bool _paying = false;
  int _selectedPayment = 0; // 0 = Par Carte, 1 = Sur Place

  void _onPay(double total) async {
    setState(() => _paying = true);
    // Simulate payment call
    await Future.delayed(const Duration(milliseconds: 1200));

    // On success: replace this screen with the success animation screen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SuccessPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Paiement', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
      ),
      // Body will be a Stack so we can position the BottomCartSummary above
      // the bottom nav area exactly like in `cart.dart`.

      body: Stack(
        children: [
          // Main scrollable content with bottom padding so last items aren't hidden
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              const SizedBox(height: 8),

              // Payment methods
              const SizedBox(height: 8),
              const Text('Moyens de Paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              _paymentOption(label: 'Par Carte', index: 0),
              const SizedBox(height: 12),
              _paymentOption(label: 'Sur Place', index: 1),

              // Order preview
              const SizedBox(height: 24),
              const Text('Ma Commande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              _orderPreview(),

              // Adresse
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Text('Adresse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)))),
                  GestureDetector(
                        onTap: () {
                          // TODO: open address management
                        },
                        child: Text('Ajouter une adresse', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary)),
                      ),
                ],
              ),
              const SizedBox(height: 8),
              _addressCard(),

                    // give enough bottom space so content isn't hidden by the summary
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ),

          // Positioned summary (same placement/dimensions as CartPage)
          Positioned(
            left: 0,
            right: 0,
            bottom: kBottomNavigationBarHeight + 64,
            child: Padding(
              // match CartPage horizontal padding
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    final cartItems = cartState is CartLoaded ? cartState.items : const [];

                    return BlocBuilder<CatalogBloc, CatalogState>(
                      builder: (context, catalogState) {
                        List<Product> sourceProducts = [];
                        if (catalogState is CatalogLoaded || catalogState is CatalogLoadingMore) {
                          sourceProducts = (catalogState as dynamic).products as List<Product>;
                        }

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
                              brand: ci.brand ?? null,
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

                        final total = productsInCart.fold<double>(0.0, (sum, p) => sum + (p.price * p.quantity));

                        return BottomCartSummary(
                          total: total,
                          onPay: _paying ? null : () => _onPay(total),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption({required String label, required int index}) {
    final selected = _selectedPayment == index;
    // Styling per request: option should NOT change background on select,
    // should have no border and only the specified shadows, and the
    // checkbox (when checked) should use color #1A1D1F.
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white, // never change background on selection
          borderRadius: BorderRadius.circular(12),
          // translate the provided CSS shadows to Flutter BoxShadows
          boxShadow: const [
            BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 1, spreadRadius: 0),
            BoxShadow(color: Color(0x3D676E76), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1),
            BoxShadow(color: Color(0x14676E76), offset: Offset(0, 2), blurRadius: 5, spreadRadius: 0),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
            // Checkbox circle — restored border, fill when selected
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // show a circular border around the checkbox
                border: Border.all(color: const Color(0xFF1A1D1F)),
                color: selected ? const Color(0xFF1A1D1F) : Colors.white,
              ),
              child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderPreview() {
    return BlocBuilder<CartBloc, CartState>(builder: (context, cartState) {
      final cartItems = cartState is CartLoaded ? cartState.items : const [];

      // show up to 3 images
      final images = cartItems.where((ci) => ci.imageUrl != null && ci.imageUrl!.isNotEmpty).map((ci) => ci.imageUrl!).take(3).toList();

      return Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 3))]),
        child: Row(
          children: [
            for (int i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(right: i == 2 ? 0 : 12),
                child: _productThumb(i < images.length ? images[i] : null),
              ),
            const Spacer(),
            // small summary
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                  Text('Voir le détail', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                ],
            )
          ],
        ),
      );
    });
  }

  Widget _productThumb(String? url) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[100]),
      child: url == null || url.isEmpty
          ? const Icon(Icons.image, color: Colors.grey)
          : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey))),
    );
  }

  Widget _addressCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          const Expanded(child: Text('12 Rue des Jasmins, Quartier El Mokrani, Ain Naadja, Alger, Algérie', style: TextStyle(fontSize: 14, color: Color(0xFF333333)))),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).colorScheme.primary)),
            child: Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
          )
        ],
      ),
    );
  }
}
