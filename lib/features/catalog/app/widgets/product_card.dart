import 'dart:async';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'package:collection/collection.dart';
import 'package:amerli_app/widgets/icon_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_event.dart';
import 'package:amerli_app/features/cart/domain/entities/cart_item.dart';

class ProductCard extends StatefulWidget {
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final String title;
  final String? subtitle;
  final double? price;
  final int? soldBy;
  final int? productId;
  
  const ProductCard({super.key, this.imageUrl, this.isFavorite = false, this.onFavoriteToggle, required this.title, this.subtitle, this.price, this.soldBy, this.productId , });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _localFavorite;
  late int _quantity;
  CartBloc? _cartBloc;
  StreamSubscription? _cartSub;
  @override
  void initState() {
    super.initState();
    _quantity = 1;
    _localFavorite = widget.isFavorite;

  }
  @override
  
  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to find CartBloc; if present, subscribe to state changes to print cart items
    try {
      final cb = BlocProvider.of<CartBloc>(context);
      if (cb != _cartBloc) {
        _cartSub?.cancel();
        _cartBloc = cb;
        _cartSub = cb.stream.listen((state) {
          if (state is CartLoaded) {
            print('Cart items (subscription):');
            for (var item in state.items) {
              print('Product: ${item.productId}, Qty: ${item.quantity}');
            }
          } else {
            print('Cart state changed: $state');
          }
        });
      }
    } catch (e) {
      // No CartBloc available in this context; ignore
      _cartSub?.cancel();
      _cartBloc = null;
      _cartSub = null;
    }
  }

  @override
  void dispose() {
    _cartSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          height: 300, // Increased card height to prevent overflow
          width: 120,
          child: Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.16),
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).colorScheme.surface,
            child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(4, 4)),
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(-4, -4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 124,
                width: 158,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.network(
                          widget.imageUrl ?? 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _localFavorite = !_localFavorite;
                            });
                            widget.onFavoriteToggle?.call();
                          },
                          child: IconCircle(isSelected: _localFavorite, asset: "assets/icons/favoris.svg", size: 20)
                        )
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 0),
                      if ((widget.subtitle ?? '').isNotEmpty)
                        Text(
                          widget.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(decoration: TextDecoration.underline, fontSize: 14, color: Theme.of(context).colorScheme.secondary, decorationColor: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500),
                        ),
                      const SizedBox(height: 0),
                      if (widget.price != null)
                        Text(
                          '${widget.price!.toStringAsFixed(2)} DZD',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      if (widget.soldBy != null) ...[
                        const SizedBox(height: 0),
                        Text(
                          'Vondu par: ${widget.soldBy}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w400),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.all(Radius.circular(32)),
                              ),
                              height: 24,
                                
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                       if (_quantity > 0) _quantity -= 1;
                                      setState(() {
                                        
                                      });
                                      /* if (widget.productId == null) return;
                                      context.read<CartBloc>().add(CartUpdateQuantityEvent(productId: widget.productId.toString(), quantity: 0)); */
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.remove, size: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('$_quantity', style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      _quantity += 1;
                                      setState(() {
                                        
                                      });
/*                                       if (widget.productId == null || widget.price == null) return;
                                      context.read<CartBloc>().add(CartAddItemEvent(CartItem(productId: widget.productId.toString(), name: widget.title, price: widget.price ?? 0.0, quantity: 1, imageUrl: widget.imageUrl)));
 */                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.add, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8,)
                          ,
                          InkWell(
                            onTap: () {
                              if (widget.productId == null || widget.price == null) return;
                              CartBloc? cartBloc;
                              try {
                                cartBloc = context.read<CartBloc>();
                              } catch (e) {
                                print('CartBloc provider not found: $e');
                                return;
                              }
                              final productIdStr = widget.productId.toString();
                              final state = cartBloc.state;
                              // Check if item is already in cart
                              if (state is CartLoaded) {
                                final existingItem = state.items.firstWhereOrNull(
                                  (item) => item.productId == productIdStr,
                                );
                                if (existingItem == null) {
                                  // Add new item with current quantity
                                  cartBloc.add(CartAddItemEvent(CartItem(
                                    productId: productIdStr,
                                    name: widget.title,
                                    price: widget.price ?? 0.0,
                                    quantity: _quantity,
                                    imageUrl: widget.imageUrl,
                                  )));
                                } else {
                                  // Update quantity
                                  cartBloc.add(CartUpdateQuantityEvent(
                                    productId: productIdStr,
                                    quantity: _quantity,
                                  ));
                                }
                                // Print cart list after change
                                print('Cart items:');
                                for (var item in state.items) {
                                  print('Product: ${item.productId}, Qty: ${item.quantity}');
                                }
                              } else {
                                // If cart not loaded, just add
                                cartBloc.add(CartAddItemEvent(CartItem(
                                  productId: productIdStr,
                                  name: widget.title,
                                  price: widget.price ?? 0.0,
                                  quantity: _quantity,
                                  imageUrl: widget.imageUrl,
                                )));
                              }
                            },
                            child: IconCircle(isSelected: true , asset: "assets/icons/panier.svg",size: 26, selectedColor: Theme.of(context).colorScheme.primary,)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}