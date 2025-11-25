import 'dart:async';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'package:collection/collection.dart';
import 'package:amerli_app/widgets/icon_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_event.dart';
import 'package:amerli_app/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:amerli_app/core/utils/top_toast.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

class ProductCard extends StatefulWidget {
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final String title;
  final String? subtitle;
  final double? price;
  final int? soldBy;
  final String? sellerName;
  final int? productId;
  final String? brand;
  final int? stock;
  final int? quantityPerBatch;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    this.imageUrl,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
    required this.title,
    this.subtitle,
    this.price,
    this.soldBy,
    this.sellerName,
    this.productId,
    this.brand,
    this.stock,
    this.quantityPerBatch,
  });

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
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      _localFavorite = widget.isFavorite;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to find CartBloc; if present, subscribe to state changes to print cart items (debug)
    try {
      final cb = BlocProvider.of<CartBloc>(context);
      if (cb != _cartBloc) {
        _cartSub?.cancel();
        _cartBloc = cb;
        _cartSub = cb.stream.listen((state) {
          if (state is CartLoaded) {
            // debug print
            for (var item in state.items) {
              // ignore: avoid_print
              print('Cart: ${item.productId} x ${item.quantity}');
            }
          }
        });
      }
    } catch (_) {
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
    // Debug print for quantityPerBatch
    if (widget.quantityPerBatch != null) {
      debugPrint(
          'ProductCard: quantityPerBatch for ${widget.title} is ${widget.quantityPerBatch}');
    }

    return SizedBox(
      height: 360.h,
      width: 120.w,
      child: Material(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(24.r),
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4.r,
                    offset: Offset(4.w, 4.h)),
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4.r,
                    offset: Offset(-4.w, -4.h)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                SizedBox(
                  height: 85.h,
                  width: 158.w,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: Image.network(
                            widget.imageUrl ??
                                'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=1170&q=80',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 32.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: SizedBox(
                          height: 24.h,
                          width: 24.w,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () {
                              setState(() {
                                _localFavorite = !_localFavorite;
                              });
                              widget.onFavoriteToggle?.call();
                            },
                            child: Container(
                              padding: EdgeInsets.all(2.r),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4.r,
                                      offset: Offset(0, 2.h)),
                                ],
                              ),
                              child: SvgPicture.asset(
                                _localFavorite
                                    ? 'assets/icons/favoris.svg'
                                    : 'assets/icons/favoris_reversed.svg',
                                width: 14.w,
                                height: 14.h,
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.primary,
                                    BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                // Content Section (Expanded)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 13.sp),
                        ),
                        if (widget.brand != null &&
                            (widget.brand ?? '').isNotEmpty) ...[
                          SizedBox(height: 1.h),
                          Text(
                            widget.brand!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontSize: 10.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          ),
                        ],
                        if ((widget.subtitle ?? '').isNotEmpty) ...[
                          SizedBox(height: 1.h),
                          Text(
                            widget.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    decoration: TextDecoration.underline,
                                    fontSize: 10.sp,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    decorationColor:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w500),
                          ),
                        ],
                        SizedBox(height: 1.h),
                        if (widget.price != null)
                          Text(
                            '${widget.price!.toStringAsFixed(2)} DZD',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp),
                          ),

                        // Quantity Per Batch
                        if (widget.quantityPerBatch != null) ...[
                          SizedBox(height: 1.h),
                          Text(
                            '${AppLanguage.perBatchOf}: ${widget.quantityPerBatch}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontSize: 11.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600),
                          ),
                        ] else if ((widget.sellerName ??
                                widget.soldBy?.toString()) !=
                            null) ...[
                          SizedBox(height: 1.h),
                          Text(
                            '${AppLanguage.soldByLabel}: ${widget.sellerName ?? widget.soldBy?.toString()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontSize: 10.sp,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w400),
                          ),
                        ],

                        // Stock
                        if (widget.stock != null) ...[
                          SizedBox(height: 1.h),
                          Text(
                            '${AppLanguage.stock}: ${widget.stock}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontSize: 10.sp,
                                    color: widget.stock! > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w400),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom Buttons Section (Fixed at bottom)
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.r)),
                          ),
                          height: 22.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_quantity > 0) _quantity -= 1;
                                  setState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.r),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(Icons.remove, size: 14.sp),
                                ),
                              ),
                              Text('$_quantity',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 12.sp)),
                              InkWell(
                                onTap: () {
                                  _quantity += 1;
                                  setState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.r),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(Icons.add, size: 14.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      InkWell(
                        onTap: () {
                          if (widget.productId == null ||
                              widget.price == null) {
                            return;
                          }
                          CartBloc? cartBloc;
                          try {
                            cartBloc = context.read<CartBloc>();
                          } catch (e) {
                            // ignore: avoid_print
                            print('CartBloc provider not found: $e');
                            return;
                          }
                          final productIdStr = widget.productId.toString();
                          final state = cartBloc.state;
                          final maxStock = widget.stock ?? 9999;

                          // Check if item is already in cart
                          if (state is CartLoaded) {
                            final existingItem = state.items.firstWhereOrNull(
                                (item) => item.productId == productIdStr);

                            final currentCartQty = existingItem?.quantity ?? 0;

                            if (currentCartQty + _quantity > maxStock) {
                              TopToast.show(context,
                                  'Quantité insuffisante. Stock disponible: $maxStock',
                                  isError: true);
                              return;
                            }

                            if (existingItem == null) {
                              cartBloc.add(CartAddItemEvent(CartItem(
                                productId: productIdStr,
                                name: widget.title,
                                price: widget.price ?? 0.0,
                                quantity: _quantity,
                                imageUrl: widget.imageUrl,
                                brand: widget.brand,
                                soldBy: widget.soldBy,
                              )));
                              // Show toast notification
                              TopToast.show(context,
                                  '$_quantity x ${widget.title} ajouté au panier');
                            } else {
                              cartBloc.add(CartUpdateQuantityEvent(
                                  productId: productIdStr,
                                  quantity: existingItem.quantity + _quantity));
                              // Show toast notification
                              TopToast.show(context,
                                  'Quantité mise à jour: ${existingItem.quantity + _quantity} x ${widget.title}');
                            }
                          } else {
                            if (_quantity > maxStock) {
                              TopToast.show(context,
                                  'Quantité insuffisante. Stock disponible: $maxStock',
                                  isError: true);
                              return;
                            }

                            cartBloc.add(CartAddItemEvent(CartItem(
                              productId: productIdStr,
                              name: widget.title,
                              price: widget.price ?? 0.0,
                              quantity: _quantity,
                              imageUrl: widget.imageUrl,
                              brand: widget.brand,
                              soldBy: widget.soldBy,
                            )));
                            // Show toast notification
                            TopToast.show(context,
                                '$_quantity x ${widget.title} ajouté au panier');
                          }
                        },
                        child: IconCircle(
                            isSelected: true,
                            asset: 'assets/icons/panier.svg',
                            size: 24.sp,
                            selectedColor:
                                Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
