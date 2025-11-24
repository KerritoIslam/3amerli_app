import 'package:amerli_app/core/config/injection.dart';
import 'package:amerli_app/core/utils/top_toast.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_event.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'package:amerli_app/features/cart/domain/entities/cart_item.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_event.dart';
import 'package:amerli_app/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/features/catalog/app/bloc/favorites_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/favorites_event.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;
  bool _localFavorite = false;
  int _loveCount = 0;
  Product? _loadedProduct;
  bool _isLoading = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _localFavorite = widget.product.isFavorit;
    _loveCount = widget.product.loveCount ?? 0;
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final datasource = sl<CatalogRemoteDataSource>();
      final productModel = await datasource.fetchProductById(widget.product.id);

      setState(() {
        _loadedProduct = productModel.toEntity();
        _loveCount = _loadedProduct?.loveCount ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Fallback to passed product
        _loadedProduct = widget.product;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _loadedProduct ?? widget.product;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientFromScheme(Theme.of(context).colorScheme),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                28.0.w,
                MediaQuery.of(context).padding.top + 8.0.h,
                28.0.w,
                MediaQuery.of(context).padding.bottom + 80.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadProductDetails,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: back, title, favorite
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                borderRadius: BorderRadius.circular(24.r),
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    'assets/icons/back_arrow.svg',
                                    width: 16.w,
                                    height: 16.h,
                                    matchTextDirection: true,
                                    colorFilter: ColorFilter.mode(
                                        Theme.of(context).colorScheme.onPrimary,
                                        BlendMode.srcIn),
                                    placeholderBuilder: (context) => Icon(
                                      Icons.arrow_back,
                                      size: 16.w,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    AppLanguage.details,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24.sp,
                                        ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 40.w,
                                height: 40.w,
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: () {
                                    final favoritesBloc = sl<FavoritesBloc>();

                                    if (_localFavorite) {
                                      favoritesBloc.add(
                                          FavoritesRemoveEvent(id: product.id));
                                      TopToast.show(
                                        context,
                                        '${product.name} ${AppLanguage.removedFromFavorites}',
                                      );
                                    } else {
                                      favoritesBloc.add(FavoritesAddEvent(
                                          userId: 0, productId: product.id));
                                      TopToast.show(
                                        context,
                                        '${product.name} ${AppLanguage.addedToFavorites}',
                                      );
                                    }

                                    // Update local state immediately for instant UI feedback
                                    setState(() {
                                      _localFavorite = !_localFavorite;
                                      if (_localFavorite) {
                                        _loveCount++;
                                      } else {
                                        if (_loveCount > 0) _loveCount--;
                                      }
                                    });

                                    // Refresh catalog after a short delay to update the product list
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      try {
                                        sl<CatalogBloc>()
                                            .add(CatalogLoadEvent());
                                      } catch (e) {
                                        // Catalog bloc might not be available
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(24.r),
                                  child: Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1.w,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      _localFavorite
                                          ? 'assets/icons/favoris.svg'
                                          : 'assets/icons/favoris_reversed.svg',
                                      width: 24.w,
                                      height: 24.h,
                                      colorFilter: ColorFilter.mode(
                                          Theme.of(context).colorScheme.primary,
                                          BlendMode.srcIn),
                                      placeholderBuilder: (context) => Icon(
                                        _localFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 20.w,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // Loading indicator
                          if (_isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),

                          // Product image
                          if (!_isLoading)
                            Column(
                              children: [
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 260.h,
                                      child: product.pics.isEmpty
                                          ? Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 64.w,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                    .withOpacity(0.6),
                                              ),
                                            )
                                          : PageView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: product.pics.length,
                                              onPageChanged: (index) {
                                                setState(() {
                                                  _currentImageIndex = index;
                                                });
                                              },
                                              itemBuilder: (context, index) {
                                                return Image.network(
                                                  product.pics[index],
                                                  fit: BoxFit.contain,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 64.w,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                            .withOpacity(0.6),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                ),
                                if (product.pics.length > 1) ...[
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      product.pics.length,
                                      (index) => Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 4.w),
                                        width: 8.w,
                                        height: 8.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex == index
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.grey.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                          if (!_isLoading) ...[
                            SizedBox(height: 8.h),

                            // Name and brand
                            Text(
                              product.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.sp,
                                  ),
                            ),

                            if (product.brand != null &&
                                product.brand!.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Text(
                                product.brand!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .extension<BrandColors>()
                                          ?.brandTeal,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Theme.of(context)
                                          .extension<BrandColors>()
                                          ?.brandTeal,
                                      fontSize: 12.sp,
                                    ),
                              ),
                            ],

                            if (product.category != null &&
                                product.category!.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                product.category!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 12.sp,
                                    ),
                              ),
                            ],

                            SizedBox(height: 8.h),

                            // Quantity per batch and price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (product.quantityPerBatch != null)
                                  Text(
                                    '${AppLanguage.soldBy}: ${product.quantityPerBatch} ${AppLanguage.units}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .extension<BrandColors>()
                                              ?.brandTeal,
                                          fontSize: 12.sp,
                                        ),
                                  ),
                                Text(
                                  '${product.price.toStringAsFixed(2)} ${AppLanguage.currency}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            // Small action buttons row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconTextButton(
                                  onTap: () {},
                                  iconAsset: 'assets/icons/bag.svg',
                                  text: AppLanguage.inStock,
                                  color: Colors.green,
                                ),
                                // Love count - NON-CLICKABLE
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/favoris.svg',
                                      width: 16.w,
                                      height: 16.h,
                                      colorFilter: const ColorFilter.mode(
                                          Colors.red, BlendMode.srcIn),
                                      placeholderBuilder: (context) => Icon(
                                        Icons.favorite,
                                        size: 16.w,
                                        color: Colors.red,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '$_loveCount',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                            fontSize: 14.sp,
                                          ),
                                    ),
                                  ],
                                ),
                                IconTextButton(
                                  onTap: () {},
                                  iconAsset: 'assets/icons/panier_reversed.svg',
                                  text: AppLanguage.deliveredIn48h,
                                  color: Colors.blue,
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            Container(
                                height: 1.h,
                                width: double.infinity,
                                color: Colors.grey.withOpacity(0.3)),

                            SizedBox(height: 12.h),

                            // Specifications
                            if (product.specifications != null &&
                                product.specifications!.isNotEmpty) ...[
                              Text(
                                AppLanguage.specifications,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 8.h),
                              ...product.specifications!.map((spec) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text('• $spec',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontSize: 14.sp)),
                                  )),
                              SizedBox(height: 12.h),
                            ],

                            // Description
                            if (product.description.isNotEmpty) ...[
                              Text(
                                AppLanguage.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 8.h),
                              Text(product.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 14.sp)),
                              SizedBox(height: 24.h),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom fixed controls
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0.h),
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
                              icon: Icon(Icons.remove, size: 16.w),
                            ),
                            Text(
                              _quantity.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontSize: 16.sp),
                            ),
                            IconButton(
                              splashColor: Colors.transparent,
                              onPressed: () {
                                setState(() => _quantity++);
                              },
                              icon: Icon(Icons.add, size: 16.w),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      InkWell(
                        onTap: () async {
                          // Add to cart logic
                          final productIdStr = product.id.toString();
                          CartBloc cartBloc;
                          try {
                            cartBloc = context.read<CartBloc>();
                          } catch (e) {
                            cartBloc = sl<CartBloc>();
                          }

                          final state = cartBloc.state;
                          if (state is CartLoaded) {
                            final existingItem = state.items.firstWhereOrNull(
                                (item) => item.productId == productIdStr);
                            if (existingItem == null) {
                              cartBloc.add(CartAddItemEvent(CartItem(
                                productId: productIdStr,
                                name: product.name,
                                price: product.price,
                                quantity: _quantity,
                                imageUrl: (product.pics.isNotEmpty)
                                    ? product.pics.first
                                    : null,
                                brand: product.brand,
                                soldBy: product.soldBy,
                              )));
                            } else {
                              cartBloc.add(CartUpdateQuantityEvent(
                                  productId: productIdStr,
                                  quantity: existingItem.quantity + _quantity));
                            }
                          } else {
                            cartBloc.add(CartAddItemEvent(CartItem(
                              productId: productIdStr,
                              name: product.name,
                              price: product.price,
                              quantity: _quantity,
                              imageUrl: (product.pics.isNotEmpty)
                                  ? product.pics.first
                                  : null,
                              brand: product.brand,
                              soldBy: product.soldBy,
                            )));
                          }

                          // show confirmation using reusable top toast
                          TopToast.show(
                              context, AppLanguage.productAddedToCart);
                        },
                        borderRadius: BorderRadius.circular(24.r),
                        child: Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/panier.svg',
                            width: 22.w,
                            height: 22.h,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn),
                            placeholderBuilder: (context) => Icon(
                              Icons.shopping_cart,
                              size: 20.w,
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
  const IconTextButton(
      {super.key,
      required this.onTap,
      required this.iconAsset,
      required this.text,
      this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 16.w,
              height: 16.h,
              colorFilter: color != null
                  ? ColorFilter.mode(color!, BlendMode.srcIn)
                  : null,
              placeholderBuilder: (context) => Icon(
                Icons.image,
                size: 16.w,
                color: color ?? Theme.of(context).iconTheme.color,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color:
                        color ?? Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14.sp,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
