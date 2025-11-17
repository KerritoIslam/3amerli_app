
import 'package:amerli_app/features/catalog/app/widgets/products_list.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amerli_app/features/catalog/app/widgets/category_grid.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/widgets/icon_circle.dart';
import 'package:amerli_app/widgets/searchbar.dart';

import 'package:amerli_app/features/catalog/app/bloc/catalog_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_event.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_state.dart';

import 'package:amerli_app/features/catalog/app/bloc/categories_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/categories_event.dart';
import 'package:amerli_app/features/catalog/app/bloc/categories_state.dart';

import 'package:amerli_app/features/catalog/app/bloc/offers_bloc.dart';

import 'package:amerli_app/features/catalog/app/bloc/offers_state.dart';
import 'package:amerli_app/core/config/injection.dart';

import 'package:go_router/go_router.dart';

import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/core/error/error_handler.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final OffersBloc _offersBloc;
  late final CategoriesBloc _categoriesBloc;
  late final CatalogBloc _catalogBloc;
  final PageController _offersPageController = PageController(viewportFraction: 1.0);
  
  // Track selected category IDs
  List<int> _selectedCategoryIds = [];
  
  @override
  void initState() {
    super.initState();
    // initialize & reuse the same bloc instances before build so providers have them
    _offersBloc = sl<OffersBloc>();
    _categoriesBloc = sl<CategoriesBloc>();
    _catalogBloc = sl<CatalogBloc>();

    // Dispatch load events after first frame so UI is ready to show loading state
    WidgetsBinding.instance.addPostFrameCallback((_) {
     // _offersBloc.add(OffersLoadEvent());
      _categoriesBloc.add(CategoriesLoadEvent());
      _catalogBloc.add(CatalogLoadEvent());
    });
  }
  
  // Fetch products with current category filter
  void _fetchProductsWithCategories() {
    // Always fetch products - include categoryIds only if list is not empty
    // ignore: avoid_print
    print('[CatalogPage] Fetching products with categoryIds: ${_selectedCategoryIds.isEmpty ? 'null (all products)' : _selectedCategoryIds}');
    _catalogBloc.add(CatalogLoadEvent(
      categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
    ));
  }
  
  // Update selected categories and refetch products
  void _updateSelectedCategories(List<int> categoryIds) {
    // Always update state and fetch, even if the list becomes empty
    // ignore: avoid_print
    print('[CatalogPage] Selected categories updated: $categoryIds');
    setState(() {
      _selectedCategoryIds = categoryIds;
    });
    // Always trigger fetch to show all products when selection is cleared
    _fetchProductsWithCategories();
  }

  @override
  void dispose() {
    _offersPageController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreAsync() {
    final completer = Completer<void>();
    final bloc = _catalogBloc;

    // Subscribe to the bloc stream and complete when we see CatalogLoaded or CatalogError
    late final StreamSubscription sub;
    sub = bloc.stream.listen((state) {
      if (state is CatalogLoaded) {
        if (!completer.isCompleted) completer.complete();
        sub.cancel();
      }
      if (state is CatalogError) {
        if (!completer.isCompleted) completer.complete();
        sub.cancel();
      }
    });

    // dispatch loadMore
    bloc.add(CatalogLoadEvent(loadMore: true, pageSize: 20));

    // safety timeout
    Future.delayed(const Duration(seconds: 6)).whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete();
        sub.cancel();
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _offersBloc),
        BlocProvider.value(value: _categoriesBloc),
        BlocProvider.value(value: _catalogBloc),
        // Provide CartBloc app-scoped so ProductCard can access it
        BlocProvider.value(value: sl<CartBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CatalogBloc, CatalogState>(
            listener: (context, state) {
              if (state is CatalogError) {
                ErrorHandler.showError(context, state.message);
              }
            },
          ),
          BlocListener<CategoriesBloc, CategoriesState>(
            listener: (context, state) {
              if (state is CategoriesError) {
                ErrorHandler.showError(context, state.message);
              }
            },
          ),
          BlocListener<OffersBloc, OffersState>(
            listener: (context, state) {
              if (state is OffersError) {
                ErrorHandler.showError(context, state.message);
              }
            },
          ),
        ],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 28, right: 28),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Bienvenue sur', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
                const SizedBox(width: 8),
                // Use the correct asset path (logo is under assets/logo/ in the project)
                SizedBox(height: 32 , width: 116, child: Image.asset('assets/logo/full_logo.png', width: 116, height: 116)),
              ],
            ),
            const SizedBox(height: 15),

            // Search + notifications
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchbar(
                      onChanged: (value) => context.read<CatalogBloc>().add(CatalogLoadEvent(query: value)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => context.push('/notifications'),
                    borderRadius: BorderRadius.circular(20),
                    child: IconCircle(
                      asset: 'assets/icons/notifications.svg',
                      isSelected: false,
                      size: 40,
                      keepIconColor: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Offers (single page view with skeleton while loading)
            /* Visibility(
              visible: false,
              child: SizedBox(
                height: 160,
                child: BlocBuilder<OffersBloc, OffersState>(builder: (context, state) {
                  if (state is OffersLoading) {
                    // show 3 skeleton pages
                    return PageView.builder(
                      controller: _offersPageController,
                      itemCount: 3,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            SkeletonBox(height: 18),
                            const SizedBox(height: 8),
                            SkeletonBox(height: 12),
                            const SizedBox(height: 6),
                            SkeletonBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  }
              
                  if (state is OffersError) {
                    ToastService.instance.showToast(context, 'Network error', type: ToastType.error);
                    return Center(child: IconButton(onPressed: () => sl<OffersBloc>().add(OffersLoadEvent()), icon: const Icon(Icons.refresh)));
                  }
              
                  if (state is OffersLoaded) {
                    final items = state.items;
                    return PageView.builder(
                      controller: _offersPageController,
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final offer = items[i];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offer.title, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(offer.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        );
                      },
                    );
                  }
              
                  return const SizedBox.shrink();
                }),
              ),
            ),
 */
            const SizedBox(height: 20),

            // Categories header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Catégories', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () => context.push('/filters/categories'),
                  child: Text('Voir tout', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint, decoration: TextDecoration.underline ,decorationColor: AppColors.hint)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Categories grid (limited to prevent overflow)
            BlocBuilder<CategoriesBloc, CategoriesState>(builder: (context, state) {
              if (state is CategoriesLoading) {
                // show skeleton grid while loading
                return categoriesSkeletonGrid(count: 6, crossAxisCount: 3, itemHeight: 90);
              }

              if (state is CategoriesError) {
                // Error handled by BlocListener
                return const SizedBox.shrink();
              }
              if (state is CategoriesLoaded) {
                // Limit to 9 categories (3 rows of 3) to prevent overflow
                // The 4th row will show "..." if there are more categories
                const maxCategoriesToShow = 9;
                final allCategories = state.items;
                final hasMore = allCategories.length > maxCategoriesToShow;
                final displayCategories = hasMore 
                    ? allCategories.take(maxCategoriesToShow).toList() 
                    : allCategories;
                
                return CategoryGrid(
                  categories: displayCategories,
                  crossAxisCount: 3,
                  itemHeight: 90,
                  showMoreIndicator: hasMore,
                  onSelectionChanged: (selectedIds) {
                    // Update selected categories with the full array
                    _updateSelectedCategories(selectedIds);
                  },
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 12),
            // Product list
            Expanded(
              child: BlocBuilder<CatalogBloc, CatalogState>(
                bloc: _catalogBloc,
                builder: (context, state) {
                // Debug logging
                // ignore: avoid_print
                print('🖼️ [CatalogPage] BlocBuilder rebuild - state: ${state.runtimeType}');
                
                final isLoading = state is CatalogLoading;
                final isLoadingMore = state is CatalogLoadingMore;
                
                if (state is CatalogError) {
                  // Error handled by BlocListener
                  return Center(
                    child: Text(
                      'Aucun produit trouvé',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint),
                    ),
                  );
                }
                if (state is CatalogLoadingMore) {
                  // Keep showing the existing items while loading more; the ProductsList will show skeleton tiles for the end
                  final products = state.products;
                  final hasMore = state.hasMore;
                  if (products.isEmpty) return Center(child: Text('Aucun produit trouvé', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint)));
                  return ProductsList(
                    products: products,
                    isLoading: true,
                    hasMore: hasMore,
                    onLoadMore: () => _loadMoreAsync(),
                  );
                }

                if (state is CatalogLoaded) {
                  final products = state.products;
                  final hasMore = state.hasMore;
                  // ignore: avoid_print
                  print('🖼️ [CatalogPage] Displaying ${products.length} products');
                  if (products.isEmpty) return Center(child: Text('Aucun produit trouvé', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint)));
                  return ProductsList(
                    products: state.products,
                    isLoading: isLoadingMore,
                    hasMore: hasMore,
                    onLoadMore: () => _loadMoreAsync(),
                  );
                }

                if (isLoading) {
                  // show skeleton grid while initial loading
                  return ProductsList(products: [], isLoading: true);
                }

                return const SizedBox.shrink();
              }),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}