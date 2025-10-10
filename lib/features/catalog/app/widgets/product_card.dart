import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final String title;
  final String? subtitle;
  final double? price;
  final int? soldBy;
  const ProductCard({super.key , this.imageUrl, this.isFavorite = false, this.onFavoriteToggle, required this.title, this.subtitle, this.price, this.soldBy});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _localFavorite;

  @override
  void initState() {
    super.initState();
    _localFavorite = widget.isFavorite;
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.16),
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        height: 260,
        width: 163,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 124,
              width: 158,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
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
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _localFavorite = !_localFavorite;
                        });
                        widget.onFavoriteToggle?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _localFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            // Subtitle underlined
            if ((widget.subtitle ?? '').isNotEmpty)
              Text(
                widget.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(decoration: TextDecoration.underline),
              ),
            const SizedBox(height: 6),
            // Price
            if (widget.price != null)
              Text(
                '\$${widget.price!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            // soldBy
            if (widget.soldBy != null) ...[
              const SizedBox(height: 6),
              Text(
                'Sold by: #${widget.soldBy}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}