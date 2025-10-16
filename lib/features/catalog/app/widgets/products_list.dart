import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:amerli_app/features/catalog/app/widgets/product_card.dart';
import 'package:amerli_app/core/ui/skeleton/skeleton.dart';

typedef ProductItemBuilder = Widget Function(BuildContext context, Product product, int index);

class ProductsList extends StatefulWidget {
  final List<Product> products;
  final Future<void> Function()? onLoadMore;
  final int columns;
  final int rowsToTrigger;
  final ProductItemBuilder? itemBuilder;
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
    if (widget.onLoadMore == null) return;
    if (_isRequestingMore) return;

    final totalItems = widget.products.length;
    final thresholdIndex = (widget.rowsToTrigger - 1) * widget.columns;

    if (totalItems <= thresholdIndex) return;

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
      if (widget.isLoading) {
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.52, // Changed from 0.6 to 0.52 for taller cards
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
          ),
        );
      }

      return const Center(child: Text('No products'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.58, // Changed from 0.6 to 0.5  - this gives cards more height
      ),
      itemCount: products.length + ((widget.isLoading && products.isNotEmpty) ? widget.columns : 0),
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

        // Provide CartBloc to ProductCard only if it's available above this widget.
        Widget card = ProductCard(
          imageUrl: product.pic,
          isFavorite: product.isFavorit,
          onFavoriteToggle: null,
          title: product.name,
          subtitle: product.description,
          price: product.price,
          soldBy: product.sellerId,
          productId: product.id,
        );
        try {
          final cartBloc = BlocProvider.of(context, listen: false) as CartBloc;
          card = BlocProvider.value(value: cartBloc, child: card);
        } catch (e) {
          // No CartBloc found above — return card without provider wrapper.
        }
        return card;
      },
    );
  }
}