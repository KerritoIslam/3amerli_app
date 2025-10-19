import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = (widget.product.pics.isNotEmpty)
        ? (widget.product.pics.length > 1 ? widget.product.pics[1] : widget.product.pics[0])
        : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientFromScheme(Theme.of(context).colorScheme),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(28.0, MediaQuery.of(context).padding.top + 8.0, 28.0, MediaQuery.of(context).padding.bottom + 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content (non-scrollable)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: back, title, favorite
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              'assets/icons/back_arrow.svg',
                              width: 16,
                              height: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                              placeholderBuilder: (context) => Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Center(
                            child: Text(
                              'Details',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/icons/favoris_reversed.svg',
                                width: 24,
                                height: 24,
                                color: Theme.of(context).colorScheme.primary,
                                placeholderBuilder: (context) => Icon(
                                  Icons.favorite_border,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Product image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 220,
                          height: 260,
                          child: (imageUrl != null && imageUrl.isNotEmpty)
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 64,
                                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Name and brand
                    Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (widget.product.brand != null && widget.product.brand!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.product.brand!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).extension<BrandColors>()?.brandTeal,
                          decoration: TextDecoration.underline,
                          decorationColor: Theme.of(context).extension<BrandColors>()?.brandTeal,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Seller and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vendu par: ${widget.product.soldBy ?? 'Inconnu'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).extension<BrandColors>()?.brandTeal,
                          ),
                        ),
                        Text(
                          '${widget.product.price.toStringAsFixed(2)} DZD',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Small action buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconTextButton(onTap: () {}, iconAsset: 'assets/icons/bag.svg', text: 'En stock', color: Colors.green),
                        IconTextButton(onTap: () {}, iconAsset: 'assets/icons/favoris_reversed.svg', text: '102', color: Colors.red),
                        IconTextButton(onTap: () {}, iconAsset: 'assets/icons/panier_reversed.svg', text: 'Livré en 48h', color: Colors.blue),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(height: 1, width: double.infinity, color: Colors.grey.withOpacity(0.3)),

                    const SizedBox(height: 12),

                    Text(
                      "Specifications :",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("1kg", style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text("Prix de l’unité", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("185.00 DZD", style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text("Date d'expiration", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("10/2026", style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 24),
                  ],
                ),

                // Bottom fixed controls
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              splashColor: Colors.transparent,
                              onPressed: () {
                                setState(() {
                                  if (_quantity > 1) _quantity--;
                                });
                              },
                              icon: const Icon(Icons.remove, size: 16),
                            ),
                            Text(
                              _quantity.toString(),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16),
                            ),
                            IconButton(
                              splashColor: Colors.transparent,
                              onPressed: () {
                                setState(() => _quantity++);
                              },
                              icon: const Icon(Icons.add, size: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/panier.svg',
                            width: 22,
                            height: 22,
                            color: Theme.of(context).colorScheme.onPrimary,
                            placeholderBuilder: (context) => Icon(
                              Icons.shopping_cart,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
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

class IconTextButton extends StatelessWidget {
  final Function onTap;
  final String iconAsset;
  final String text;
  final Color? color;
  const IconTextButton({super.key , required this.onTap, required this.iconAsset, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
          color: Colors.transparent,
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 16,
              height: 16,
              color: color,
              placeholderBuilder: (context) => Icon(
                Icons.image,
                size: 16,
                color: color ?? Theme.of(context).iconTheme.color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}