import 'package:amerli_app/widgets/icon_circle.dart';
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
      borderRadius: BorderRadius.circular(24),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        height: 260,
        width: 163,
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
                      height: 20 ,
                      width: 20,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _localFavorite = !_localFavorite;
                          });
                          widget.onFavoriteToggle?.call();
                        },
                        child : IconCircle(isSelected: _localFavorite , asset: "assets/icons/favoris.svg",size: 20,)

                      )
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            // Subtitle underlined
            if ((widget.subtitle ?? '').isNotEmpty)
              Text(
                widget.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(decoration: TextDecoration.underline , fontSize: 14 ,color: Theme.of(context).colorScheme.secondary , decorationColor: Theme.of(context).colorScheme.secondary , fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 6),
            // Price
            if (widget.price != null)
              Text(
                '${widget.price!.toStringAsFixed(2)} DZD',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            // soldBy
            if (widget.soldBy != null) ...[
              const SizedBox(height: 6),
              Text(
                'Vondu par: ${widget.soldBy}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12 , color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w400),
              ),
            ],

              ],),
            )
          ],
        ),
      ),
    );
  }
}