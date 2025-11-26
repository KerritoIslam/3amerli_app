import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:amerli_app/features/catalog/app/widgets/product_card.dart';
import 'package:amerli_app/features/catalog/app/pages/product_details_page.dart';
import 'package:amerli_app/core/ui/skeleton/skeleton.dart';
import 'package:amerli_app/features/catalog/app/bloc/favorites_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/favorites_event.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_event.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:amerli_app/core/config/injection.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:amerli_app/core/utils/top_toast.dart';

typedef ProductItemBuilder = Widget Function(
    BuildContext context, Product product, int index);

class ProductsList extends StatefulWidget {
  final List<Product> products;
  final Future<void> Function()? onLoadMore;
  final int columns;
  final int rowsToTrigger;
  final ProductItemBuilder? itemBuilder;
  final bool isLoading;
  final bool hasMore;

  const ProductsList({
    super.key,
    required this.products,
    this.onLoadMore,
    this.columns = 2,
    this.rowsToTrigger = 7,
    this.itemBuilder,
    this.isLoading = false,
    this.hasMore = true,
  }) : assert(columns > 0 && rowsToTrigger > 0);

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  final ScrollController _scrollController = ScrollController();
  bool _isRequestingMore = false;
  int _lastProductsLength = 0;

  @override
  void initState() {
    super.initState();
    _lastProductsLength = widget.products.length;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.products.length > _lastProductsLength) {
      _isRequestingMore = false;
      _lastProductsLength = widget.products.length;
    }
  }

  void _onScroll() {
    if (!widget.hasMore) return;

    // final totalItems = widget.products.length;
    // final thresholdIndex = (widget.rowsToTrigger - 1) * widget.columns;

    // if (totalItems <= thresholdIndex) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    if (current >= maxScroll * 0.6 || (maxScroll - current) <= 300) {
      _isRequestingMore = true;
      final future = widget.onLoadMore?.call();
      if (future != null) {
        future.whenComplete(() {
          _isRequestingMore = false;
        });
      } else {
        _isRequestingMore = false;
      }
      debugPrint(
          'ProductsList: load more triggered by scroll (threshold row ${widget.rowsToTrigger})');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.products;

    if (products.isEmpty) {
      if (widget.isLoading) {
        return GridView.builder(
          // No controller, uses PrimaryScrollController if available
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.64,
          ),
          itemCount: widget.columns * 2,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  height: 120.h,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                SizedBox(height: 8.h),
                SkeletonBox(
                  height: 14.h,
                  width: 100.w,
                ),
                SizedBox(height: 4.h),
                SkeletonBox(
                  height: 12.h,
                  width: 60.w,
                ),
                const Spacer(),
                SkeletonBox(
                  height: 16.h,
                  width: 80.w,
                ),
              ],
            ),
          ),
        );
      }

      return const Center(child: Text('No products'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!widget.hasMore) return false;
        if (scrollInfo.metrics.axis != Axis.vertical) return false;

        final maxScroll = scrollInfo.metrics.maxScrollExtent;
        final current = scrollInfo.metrics.pixels;

        if (current >= maxScroll * 0.6 || (maxScroll - current) <= 300) {
          if (!_isRequestingMore) {
            _isRequestingMore = true;
            final future = widget.onLoadMore?.call();
            if (future != null) {
              future.whenComplete(() {
                if (mounted) {
                  setState(() {
                    _isRequestingMore = false;
                  });
                }
              });
            } else {
              _isRequestingMore = false;
            }
            debugPrint(
                'ProductsList: load more triggered by scroll (threshold row ${widget.rowsToTrigger})');
          }
        }
        return false;
      },
      child: GridView.builder(
        // No controller, uses PrimaryScrollController if available
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
          bottom: widget.hasMore
              ? 8
              : 100, // Add extra space when no more items to prevent bottom nav covering
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.64,
        ),
        itemCount: products.length +
            ((widget.isLoading && products.isNotEmpty) ? widget.columns : 0),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    height: 120.h,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  SizedBox(height: 8.h),
                  SkeletonBox(
                    height: 14.h,
                    width: 100.w,
                  ),
                  SizedBox(height: 4.h),
                  SkeletonBox(
                    height: 12.h,
                    width: 60.w,
                  ),
                  const Spacer(),
                  SkeletonBox(
                    height: 16.h,
                    width: 80.w,
                  ),
                ],
              ),
            );
          }

          final product = products[index];

          // Keep the builder-based trigger as a backup or alternative
          final itemsFromEnd = widget.rowsToTrigger * widget.columns;
          final thresholdIndex =
              (products.length - itemsFromEnd).clamp(0, products.length);

          if (!_isRequestingMore &&
              widget.hasMore &&
              widget.onLoadMore != null &&
              index >= thresholdIndex) {
            // Debounce/throttle is handled by _isRequestingMore, but we need to reset it eventually
            // The scroll listener handles the main logic, but this is good for initial loads
            // where scroll might not happen yet.
            // However, to avoid double triggers, we can rely on _isRequestingMore flag.
            // We'll leave this here but it shares the flag.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_isRequestingMore && mounted) {
                _isRequestingMore = true;
                final future = widget.onLoadMore!.call();
                future.whenComplete(() {
                  if (mounted) {
                    setState(() {
                      _isRequestingMore = false;
                    });
                  }
                });
              }
            });
          }

          if (widget.itemBuilder != null) {
            return widget.itemBuilder!(context, product, index);
          }

          // Render ProductCard; CartBloc is provided by parent pages
          final card = ProductCard(
            imageUrl: product.pics.isNotEmpty ? product.pics.first : null,
            isFavorite: product.isFavorit,
            onFavoriteToggle: () {
              // Toggle favorite in backend
              try {
                final favoritesBloc = sl<FavoritesBloc>();
                if (product.isFavorit) {
                  // Remove from favorites - pass productId as id
                  favoritesBloc.add(FavoritesRemoveEvent(id: product.id));
                } else {
                  // Add to favorites - userId will be fetched from auth service in the repository
                  favoritesBloc
                      .add(FavoritesAddEvent(userId: 0, productId: product.id));
                }

                // Refresh catalog to reflect changes after a short delay
                Future.delayed(const Duration(milliseconds: 500), () {
                  final catalogBloc = sl<CatalogBloc>();
                  catalogBloc.add(CatalogLoadEvent(
                      loadMore: false, timestamp: DateTime.now()));
                });

                // Show toast
                TopToast.show(
                  context,
                  product.isFavorit
                      ? '${product.name} ${AppLanguage.removedFromFavorites}'
                      : '${product.name} ${AppLanguage.addedToFavorites}',
                );
              } catch (e) {
                debugPrint('Error toggling favorite: $e');
                TopToast.show(
                  context,
                  AppLanguage.error,
                  isError: true,
                );
              }
            },
            title: product.name,
            subtitle: product.description,
            price: product.price,
            soldBy: product.soldBy,
            sellerName: product.sellerName,
            brand: product.brand,
            productId: product.id,
            stock: product.stock,
            quantityPerBatch: product.quantityPerBatch,
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => ProductDetailsPage(product: product)));
              if (context.mounted) {
                sl<CatalogBloc>().add(CatalogLoadEvent());
              }
            },
          );
          return card;
        },
      ),
    );
  }
}
