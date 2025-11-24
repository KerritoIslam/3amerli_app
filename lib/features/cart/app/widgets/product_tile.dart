import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductTile extends StatefulWidget {
  final Product product;
  final int quantity;
  final Function(int) onQuantityChange;
  const ProductTile(
      {super.key,
      required this.product,
      required this.quantity,
      required this.onQuantityChange});

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  @override
  Widget build(BuildContext context) {
    // debug: product pics
    // ignore: avoid_print
    print('product tile');
    // ignore: avoid_print
    print(widget.product.pics);
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8.r,
              offset: Offset(0, 2.h)),
        ],
      ),
      padding: EdgeInsets.all(4.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: 100.w,
              height: 112.h,
              color: Colors.grey.shade200,
              child: (widget.product.pics.isNotEmpty
                          ? widget.product.pics.first
                          : '')
                      .isNotEmpty
                  ? Image.network(
                      widget.product.pics.first,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2.w,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 32.sp,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 32.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
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
                SizedBox(height: 6.h),
                Text(
                  '${widget.product.price.toStringAsFixed(2)} DZD',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp), // Added fontSize for consistency
                ),
                SizedBox(height: 2.h),
                Text(
                  'Vendu par ${widget.product.soldBy ?? 12}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp, color: cs.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Trailing controls (delete + qty)
          Padding(
            padding: EdgeInsets.all(4.0.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Delete circle
                InkWell(
                  onTap: () => widget.onQuantityChange(0),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 24.w,
                    height: 24.w, // Keep it square
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surface,
                      border: Border.all(color: cs.primary, width: 2.w),
                    ),
                    padding: EdgeInsets.all(4.r),
                    child: SvgPicture.asset('assets/icons/trash.svg',
                        width: 8.w,
                        height: 8.w,
                        colorFilter:
                            ColorFilter.mode(cs.primary, BlendMode.srcIn)),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 28.h,
                  width: 72.w,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(32.r)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .extension<BrandColors>()
                              ?.brandTeal,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: InkWell(
                          onTap: () {
                            final next =
                                widget.quantity > 0 ? widget.quantity - 1 : 0;
                            widget.onQuantityChange(next);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(3.0.r),
                            child: Icon(Icons.remove,
                                size: 16.sp, color: cs.surface),
                          ),
                        ),
                      ),
                      Text('${widget.quantity}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: cs.onSecondary, fontSize: 14.sp)),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .extension<BrandColors>()
                              ?.brandTeal,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: InkWell(
                          onTap: () =>
                              widget.onQuantityChange(widget.quantity + 1),
                          child: Padding(
                            padding: EdgeInsets.all(3.0.r),
                            child:
                                Icon(Icons.add, size: 16.sp, color: cs.surface),
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
