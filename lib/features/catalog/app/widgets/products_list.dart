import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:amerli_app/features/catalog/app/widgets/product_card.dart';
import 'package:amerli_app/core/ui/skeleton/skeleton.dart';

typedef ProductItemBuilder = Widget Function(BuildContext context, Product product, int index);

class ProductsList extends StatefulWidget {
  /// The list of products to display
  final List<Product> products;

  /// Called when the user scrolls to the [rowsToTrigger] row (default 7)
  /// Use this to load the next page. The callback should complete when loading finishes.
  final Future<void> Function()? onLoadMore;

  /// Number of columns in the grid (default 2)
  final int columns;

  /// The row index (1-based) at which to trigger load more. Default is 7.
  final int rowsToTrigger;

  /// Optional custom item builder. If omitted, the default ProductCard will be used.
  final ProductItemBuilder? itemBuilder;

  /// Optional flag to show a loading indicator at the end while next page is loading.
  final bool isLoading;

  const ProductsList({
    super.key,
    required this.products,
    this.onLoadMore,
    this.columns = 2,
    this.rowsToTrigger = 7,
    this.itemBuilder,
    this.isLoading = false,
  }) : assert(columns > 0 && rowsToTrigger > 0);

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  final ScrollController _scrollController = ScrollController();

  /// Prevent duplicate load calls while waiting for the parent to append results
  bool _isRequestingMore = false;

  /// Track last products length so we can reset the requesting flag when new items arrive
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
    // If parent appended products, allow requesting more again
    if (widget.products.length > _lastProductsLength) {
      _isRequestingMore = false;
      _lastProductsLength = widget.products.length;
    }
  }

  void _onScroll() {
    if (widget.onLoadMore == null) return;

  // if already requesting, skip
  if (_isRequestingMore) return;

    // When grid scroll reaches near the threshold item (7th row), trigger onLoadMore.
    final totalItems = widget.products.length;
    final thresholdIndex = (widget.rowsToTrigger - 1) * widget.columns; // 0-based index of first item in the target row

    // If we have fewer items than threshold, don't request yet
    if (totalItems <= thresholdIndex) return;

    // Decide based on scroll position: if reachable extent shows the threshold index
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    // Trigger either when we've scrolled past 60% of the max scroll or when within 300 px to the end
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
      debugPrint('ProductsList: load more triggered by scroll (threshold row ${widget.rowsToTrigger})');
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
      return const Center(child: Text('No products'));
    }

    // Grid with 2 items per row by default
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Use a reasonable aspect ratio; tweak if your ProductCard has different dimensions
        childAspectRatio: 0.6,
      ),
      itemCount: products.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // If showing loading tile at the end
        if (index >= products.length) {
          // show a skeleton-style card
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(height: 120, borderRadius: BorderRadius.all(Radius.circular(10))),
                SizedBox(height: 8),
                SkeletonBox(height: 14),
                SizedBox(height: 4),
                SkeletonBox(height: 12),
                SizedBox(height: 6),
                SkeletonBox(height: 16),
              ],
            ),
          );
        }

        final product = products[index];

        // Trigger page-based load when the builder reaches the first item of the rowsToTrigger row
        final thresholdIndex = (widget.rowsToTrigger - 1) * widget.columns;
        if (!_isRequestingMore && widget.onLoadMore != null && index == thresholdIndex) {
          _isRequestingMore = true;
          final future = widget.onLoadMore!.call();
          future.whenComplete(() {
            _isRequestingMore = false;
          });
          debugPrint('ProductsList: load more triggered by builder at index $index (row ${widget.rowsToTrigger})');
        }

        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(context, product, index);
        }

        // Default product card rendering using the shared ProductCard widget
        return ProductCard(
          imageUrl: product.pic,
          isFavorite: false,
          onFavoriteToggle: null,
          title: product.name,
          subtitle: product.description,
          price: product.price,
          soldBy: product.sellerId,
        );
      },
    );
  }
}