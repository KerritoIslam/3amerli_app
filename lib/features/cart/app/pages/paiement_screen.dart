import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'package:amerli_app/features/cart/domain/entities/cart_item.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_state.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/features/success/app/pages/success_page.dart';
import 'package:amerli_app/features/orders/app/bloc/orders_bloc.dart';
import 'package:amerli_app/features/orders/app/bloc/orders_event.dart';
import 'package:amerli_app/features/orders/app/bloc/orders_state.dart';
import 'package:amerli_app/features/orders/domain/entities/order.dart';
import 'package:amerli_app/features/orders/utils/order_payload_builder.dart';
import 'package:amerli_app/core/config/injection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/widgets/bottom_cart_summary.dart';
import 'package:amerli_app/features/cart/app/pages/address_selection_page.dart';
import 'package:amerli_app/features/cart/app/pages/payment_webview_page.dart';


class PaiementScreen extends StatefulWidget {
  const PaiementScreen({super.key});

  @override
  State<PaiementScreen> createState() => _PaiementScreenState();
}

class _PaiementScreenState extends State<PaiementScreen> {
  bool _paying = false;
  bool _animationComplete = false;
  String? _pendingCheckoutUrl; // Store checkout URL when order is created
  Map<String, dynamic>? _selectedAddress; // Store selected address
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash; // Default to cash
  bool _orderCreated = false; // Track if order was successfully created
  String? _createdOrderId; // Store the created order ID
  Order? _createdOrder; // Store the full created order

  @override
  void initState() {
    super.initState();
    // Listen to OrdersBloc state changes
    sl<OrdersBloc>().stream.listen((state) {
      if (!mounted) return;
      
      if (state is OrderCreated) {
        // Order created successfully - store the checkout URL and mark order as created
        _pendingCheckoutUrl = state.checkoutUrl;
        _orderCreated = true;
        _createdOrderId = state.order.id; // Store the order ID
        _createdOrder = state.order; // Store the full order
        // ignore: avoid_print
        print('✅ Order created! Order ID: $_createdOrderId | CheckoutUrl: $_pendingCheckoutUrl | Payment Method: $_selectedPaymentMethod | Animation complete: $_animationComplete');
        
        // If animation already completed, navigate immediately
        if (_animationComplete) {
          // ignore: avoid_print
          print('🚀 Animation already done, navigating now...');
          _navigateAfterOrder(_pendingCheckoutUrl);
        } else {
          // ignore: avoid_print
          print('⏳ Waiting for animation to complete...');
        }
        // Otherwise, animation will trigger navigation when complete
      } else if (state is OrdersError) {
        // ignore: avoid_print
        print('❌ Error creating order: ${state.message}');
        setState(() {
          _paying = false;
          _animationComplete = false;
          _pendingCheckoutUrl = null;
          _orderCreated = false;
          _createdOrderId = null;
          _createdOrder = null;
        });
      }
    });
  }

  void _navigateAfterOrder(String? checkoutUrl) {
    // ignore: avoid_print
    print('🎯 _navigateAfterOrder called with URL: $checkoutUrl | Payment Method: $_selectedPaymentMethod');
    
    // For CASH payment, always go to success page regardless of checkoutUrl
    if (_selectedPaymentMethod == PaymentMethod.cash) {
      // ignore: avoid_print
      print('💵 Cash payment detected, going to success page with order ID: $_createdOrderId');
      
      // Reset paying state
      setState(() {
        _paying = false;
        _animationComplete = false;
        _pendingCheckoutUrl = null;
        _orderCreated = false;
      });
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SuccessPage(
          orderId: _createdOrderId,
          paymentMethod: 'CASH',
          order: _createdOrder,
        )),
      );
      return;
    }
    
    // For EPAYMENT, check if we have a checkout URL
    if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
      // Online payment - open in WebView
      // ignore: avoid_print
      print('🌐 Opening payment URL in WebView...');
      
      // Reset paying state
      setState(() {
        _paying = false;
        _animationComplete = false;
        _pendingCheckoutUrl = null;
        _orderCreated = false;
      });
      
      // Navigate to WebView page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentWebViewPage(checkoutUrl: checkoutUrl),
        ),
      );
    } else {
      // No checkout URL for online payment - show error or go to success
      // ignore: avoid_print
      print('⚠️ Online payment but no checkout URL, going to success page...');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SuccessPage(
          orderId: _createdOrderId,
          paymentMethod: 'EPAYMENT',
        )),
      );
    }
  }

  void _onPay(List<CartItem> cartItems) async {
    // Validate that an address is selected
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une adresse de livraison'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // start local animation overlay
    setState(() => _paying = true);

    try {
      // Use selected payment method from UI
      final paymentMethod = _selectedPaymentMethod;

      // Build order payload
      final Map<String, dynamic> payload;
      
      // Check if the selected address has an ID (existing address)
      if (_selectedAddress!.containsKey('id') && _selectedAddress!['id'] != null) {
        // Use addressId for existing address
        payload = OrderPayloadBuilder.build(
          cartItems: cartItems,
          paymentMethod: paymentMethod,
          addressId: _selectedAddress!['id'],
        );
      } else {
        // Use address object for new address
        final address = OrderPayloadBuilder.buildAddress(
          street: _selectedAddress!['street'] ?? '',
          city: _selectedAddress!['city'] ?? '',
          district: _selectedAddress!['district'] ?? '',
        );
        
        payload = OrderPayloadBuilder.build(
          cartItems: cartItems,
          paymentMethod: paymentMethod,
          address: address,
        );
      }

      // Dispatch order creation event
      if (!mounted) return;
      sl<OrdersBloc>().add(OrdersCreateEvent(payload: payload));

      // State listener will handle navigation when order is created
    } catch (e) {
      // Print error instead of showing snackbar
      // ignore: avoid_print
      print('Error creating order: $e');
      if (mounted) {
        setState(() {
          _paying = false;
          _orderCreated = false;
          _createdOrderId = null;
        });
      }
    }
  }

  Future<void> _openAddressSelection() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddressSelectionPage(currentAddress: _selectedAddress),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/back_arrow.svg',
              width: 14,
              height: 14,
              color: Theme.of(context).colorScheme.onPrimary,
              placeholderBuilder: (context) => Icon(
                Icons.arrow_back,
                size: 14,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
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

              // Payment Method Selection (moved to top)
              const SizedBox(height: 16),
              const Text('Mode de paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              _paymentMethodSelection(),

              // Order preview
              const SizedBox(height: 20),
              const Text('Mes Produits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              _orderPreview(),

              // Adresse
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Text('Adresse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)))),
                  GestureDetector(
                        onTap: _openAddressSelection,
                        child: Text(
                          _selectedAddress == null ? 'Ajouter une adresse' : 'Modifier',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 8),
              _selectedAddress != null ? _addressCard() : _emptyAddressCard(),

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
                        final List<CartItem> cartItems = cartState is CartLoaded ? cartState.items : const [];

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

                            final total = productsInCart.fold<double>(0.0, (sum, p) => sum + (p.price * p.quantity));

                            // Size matching the BottomCartSummary placement (matches horizontal padding)
                            final double w = MediaQuery.of(context).size.width - 40;
                            final double h = 56;

                            // Render the BottomCartSummary always but allow replacing the pay button
                            // with the animation overlay when paying.
                            return BottomCartSummary(
                              total: total,
                              onPay: _paying ? null : () => _onPay(cartItems),
                              payButton: _paying
                                  ? PaymentAnimationOverlay(
                                      width: w,
                                      height: h,
                                      onComplete: () {
                                        // ignore: avoid_print
                                        print('🎬 Animation complete! Order Created: $_orderCreated | Payment Method: $_selectedPaymentMethod');
                                        setState(() => _animationComplete = true);
                                        // If order was created while animation was running, navigate now
                                        if (_orderCreated) {
                                          // ignore: avoid_print
                                          print('✨ Order already created, navigating now...');
                                          _navigateAfterOrder(_pendingCheckoutUrl);
                                        } else {
                                          // ignore: avoid_print
                                          print('⏰ Still creating order, will navigate when done...');
                                        }
                                      },
                                    )
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
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Silently handle error and show placeholder
                  return const Icon(Icons.broken_image, color: Colors.grey, size: 24);
                },
              ),
            ),
    );
  }

  Widget _addressCard() {
    final street = _selectedAddress!['street'] ?? '';
    final district = _selectedAddress!['district'] ?? '';
    final city = _selectedAddress!['city'] ?? '';
    final fullAddress = [street, district, city].where((s) => s.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              fullAddress.isNotEmpty ? fullAddress : 'Adresse incomplète',
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: Icon(
              Icons.check,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
    );
  }

  Widget _emptyAddressCard() {
    return GestureDetector(
      onTap: _openAddressSelection,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.add_location_alt, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Appuyez pour ajouter une adresse de livraison',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodSelection() {
    return Column(
      children: [
        // Cash option
        _paymentMethodOption(
          method: PaymentMethod.cash,
          icon: Icons.money,
          title: 'Paiement en espèces',
          description: 'Payez à la livraison',
        ),
        const SizedBox(height: 8),
        // Online payment option
        _paymentMethodOption(
          method: PaymentMethod.epayment,
          icon: Icons.credit_card,
          title: 'Paiement en ligne',
          description: 'Carte bancaire (CIB/EDAHABIA)',
        ),
      ],
    );
  }

  Widget _paymentMethodOption({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}


class PaymentAnimationOverlay extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onComplete;

  const PaymentAnimationOverlay({super.key, required this.width, required this.height, required this.onComplete});

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
