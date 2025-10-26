import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_state.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/features/success/app/pages/success_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    // start local animation overlay
    setState(() => _paying = true);
    // The animation overlay will navigate to SuccessPage when done.
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The normal BottomCartSummary
                    BlocBuilder<CartBloc, CartState>(
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

                            // Size matching the BottomCartSummary placement (matches horizontal padding)
                            final double w = MediaQuery.of(context).size.width - 40;
                            final double h = 56;

                            // Render the BottomCartSummary always but allow replacing the pay button
                            // with the animation overlay when paying.
                            return BottomCartSummary(
                              total: total,
                              onPay: _paying ? null : () => _onPay(total),
                              payButton: _paying
                                  ? PaymentAnimationOverlay(width: w, height: h, onComplete: () {
                                      if (!mounted) return;
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SuccessPage()));
                                    })
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ],
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
    // If this is the second payment option (index == 1) and the payment
    // animation is running, animate a slight scale-down and upward translation
    // so it looks like the truck is lifting it.
    final Widget optionContent = GestureDetector(
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

    if (index == 1) {
      // animate lift/scale when paying
      final double target = _paying ? 1.0 : 0.0;
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: target),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutBack,
        builder: (context, val, child) {
          // val: 0.0 -> idle, 1.0 -> lifted
          final double lift = -8.0 * val; // lift up to 8px
          final double scale = 1.0 - (0.08 * val); // scale down up to 8%
          return Transform.translate(
            offset: Offset(0, lift),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
        child: optionContent,
      );
    }

    return optionContent;
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


class PaymentAnimationOverlay extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onComplete;

  const PaymentAnimationOverlay({Key? key, required this.width, required this.height, required this.onComplete}) : super(key: key);

  @override
  State<PaymentAnimationOverlay> createState() => _PaymentAnimationOverlayState();
}

class _PaymentAnimationOverlayState extends State<PaymentAnimationOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _colorAnim;
  late final Animation<double> _movementAnim;
  late final Animation<double> _textFadeAnim;
  late final Animation<double> _box2Opacity;
  late final Animation<double> _box1Opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

    _colorAnim = ColorTween(begin: const Color(0xFF8CD630), end: const Color(0xFF04272D)).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.12, curve: Curves.easeIn)),
    );

    _textFadeAnim = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.18, curve: Curves.easeOut)));

  // box1 should fade in before the truck starts moving so it appears simultaneously
  // with the overlay (and slightly prior to the truck movement).
  _box1Opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.12, curve: Curves.easeIn)));

    _movementAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.12, 0.92, curve: Curves.linear)),
    );

    _box2Opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.88, 0.95, curve: Curves.easeIn)));

    _controller.addStatusListener((s) async {
      if (s == AnimationStatus.completed) {
        // small pause then trigger completion
        await Future.delayed(const Duration(milliseconds: 350));
        if (mounted) widget.onComplete();
      }
    });

    // start animation
    _controller.forward();
  // no preload: attempt to render box_1.svg directly via SvgPicture.asset
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = widget.width;
    final double h = widget.height; // container height (keeps space for original BottomCartSummary)
    // We'll render the animated pill centered vertically inside this container.
    final double pillHeight = 56.0; // visual button height
    final double pillPadding = 12.0; // inner padding inside pill
    final double truckW = 42.0;
    final double truckH = pillHeight - 16.0; // fit with padding inside pill
    final double boxW = 36.0;
    final double boxH = pillHeight - 20.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = _colorAnim.value ?? const Color(0xFF04272D);
        final textOpacity = _textFadeAnim.value;
        final mov = _movementAnim.value;

        // pill coordinates (we center the pill inside the container)
        final double pillLeft = 0.0; // we draw pill full width
        final double pillWidth = w;

        // For right->left motion inside the pill: truck starts at rightPos and moves to endPos overlapping the box
        final double rightPos = pillLeft + pillWidth - pillPadding - truckW; // starting X for truck inside pill
        // move end position so the truck slightly overlaps the box to look like lifting it
        final double boxLeft = pillLeft + pillPadding;
        final double endPos = boxLeft + boxW - (truckW * 0.25);
        final double truckLeft = endPos + (rightPos - endPos) * (1.0 - mov);

        final double truckRight = truckLeft + truckW;
        final double trailRightAnchor = rightPos + truckW; // extreme right where trail can extend to

        // Build the animated pill centered vertically inside the container
        return SizedBox(
          width: w,
          height: h,
          child: Center(
            child: Container(
              width: w,
              height: pillHeight,
              // look like the original button: pill shaped
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(28.0)),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  // dashed trail painter behind truck (use pill dimensions)
                  CustomPaint(
                    size: Size(w, pillHeight),
                    painter: _DashTrailPainter(
                      truckRight: truckRight,
                      trailRightAnchor: trailRightAnchor,
                      centerY: pillHeight / 2,
                      progress: mov,
                    ),
                  ),

                  // button text (fade)
                  Center(
                    child: Opacity(
                      opacity: textOpacity,
                      child: const Text('Payer ma commande', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),

                  // Truck (spawn RIGHT, move LEFT)
                  Positioned(
                    left: truckLeft,
                    top: (pillHeight - truckH) / 2.0,
                    width: truckW,
                    height: truckH,
                    child: SvgPicture.asset('assets/icons/truck.svg', width: truckW, height: truckH, fit: BoxFit.contain),
                  ),

                  // Box (anchored LEFT) - crossfade to box_2 when truck reaches
                  Positioned(
                    left: boxLeft,
                    top: (pillHeight - boxH) / 2.0,
                    width: boxW,
                    height: boxH,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Fade-in box_1 early so it appears before truck movement.
                        // Attempt to render the original SVG asset directly. If it can't be
                        // rendered by flutter_svg, the framework will show nothing — but
                        // we still crossfade to box_2 when the truck arrives.
                        Opacity(
                          opacity: _box1Opacity.value * (1.0 - _box2Opacity.value),
                          child: Image.asset('assets/icons/box_1.png', width: boxW, height: boxH, fit: BoxFit.contain),
                        ),
                        // box_2 crossfades and scales down slightly as it appears so it
                        // looks like the truck is grabbing/holding it.
                        Opacity(
                          opacity: _box2Opacity.value,
                          child: Builder(builder: (context) {
                            // scale down up to ~22% when fully appeared
                            final double scale = 1.0 - (0.22 * _box2Opacity.value);
                            // lift slightly up to 6px to emphasize the grab
                            final double lift = -6.0 * _box2Opacity.value;
                            return Transform.translate(
                              offset: Offset(0, lift),
                              child: Transform.scale(
                                scale: scale,
                                alignment: Alignment.center,
                                child: SvgPicture.asset('assets/icons/box_2.svg', width: boxW, height: boxH, fit: BoxFit.contain),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashTrailPainter extends CustomPainter {
  // right edge of the truck (current)
  final double truckRight;
  // anchor point to the rightmost trail limit (initial rightmost truck position + truckW)
  final double trailRightAnchor;
  final double centerY;
  final double progress;

  _DashTrailPainter({required this.truckRight, required this.trailRightAnchor, required this.centerY, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // if there's no room to the right, nothing to draw
    if (trailRightAnchor <= truckRight) return;

    const double dashLen = 6.0;
    const double gap = 6.0;

    // visible length behind the truck grows with progress
    final double visibleLength = (trailRightAnchor - truckRight) * progress;
    final double visibleUpTo = truckRight + visibleLength;

    double x = truckRight;
    while (x < visibleUpTo) {
      final double x2 = (x + dashLen).clamp(x, visibleUpTo);
      canvas.drawLine(Offset(x, centerY), Offset(x2, centerY), paint);
      x += dashLen + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashTrailPainter oldDelegate) {
    return oldDelegate.truckRight != truckRight || oldDelegate.progress != progress || oldDelegate.trailRightAnchor != trailRightAnchor;
  }
}
