import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProductTile extends StatefulWidget {
  final Product product;
  final int quantity;
  final Function(int) onQuantityChange;
  const ProductTile({super.key, required this.product, required this.quantity, required this.onQuantityChange});

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  
  @override
  Widget build(BuildContext context) {
    print('product tile');
    print(widget.product.pic);
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 100,
              height: 112,
              color: Colors.grey.shade200,
              child: (widget.product.pic ?? '').isNotEmpty
                  ? Image.network(widget.product.pic!, fit: BoxFit.cover)
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 12),
          // Middle content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                if ((widget.product.description).isNotEmpty)
                  Text(
                    widget.product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: cs.secondary,
                          color: cs.secondary,
                        ),
                  ),
                const SizedBox(height: 6),
                Text(
                  '${widget.product.price.toStringAsFixed(2)} DZD',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vendu par ${widget.product.sellerId ?? 12}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, color: cs.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Trailing controls (delete + qty)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Delete circle
                InkWell(
                  onTap: () => widget.onQuantityChange(0),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surface,
                      border: Border.all(color: cs.primary, width: 2),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: SvgPicture.asset('assets/icons/trash.svg', width: 8, height: 8, color: cs.primary),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 28,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).extension<BrandColors>()?.brandTeal,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: InkWell(
                          onTap: () {
                            final next = widget.quantity > 0 ? widget.quantity - 1 : 0;
                            widget.onQuantityChange(next);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(Icons.remove, size: 16, color: cs.surface),
                          ),
                        ),
                      ),
                      Text('${widget.quantity}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSecondary)),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).extension<BrandColors>()?.brandTeal,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: InkWell(
                          onTap: () => widget.onQuantityChange(widget.quantity + 1),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(Icons.add, size: 16, color: cs.surface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}