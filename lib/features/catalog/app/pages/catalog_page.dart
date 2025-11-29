import 'package:amerli_app/features/catalog/app/widgets/products_list.dart';
import 'dart:async';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

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
  final ScrollController _scrollController = ScrollController();
  final PageController _offersPageController =
      PageController(viewportFraction: 1.0);

  // Track selected category IDs
  List<int> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    // initialize & reuse the same bloc instances before build so providers have them
    _offersBloc = sl<OffersBloc>();
    _categoriesBloc = sl<CategoriesBloc>();
    _catalogBloc = sl<CatalogBloc>();

    _scrollController.addListener(_onScroll);

    // Dispatch load events after first frame so UI is ready to show loading state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _offersBloc.add(OffersLoadEvent());
      _categoriesBloc.add(CategoriesLoadEvent());
      _catalogBloc.add(CatalogLoadEvent());
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.7) {
      final state = _catalogBloc.state;
      if (state is CatalogLoaded && state.hasMore) {
        _loadMoreAsync();
      } else if (state is CatalogLoadingMore && state.hasMore) {
        // Already loading, do nothing
      }
    }
  }

  // Fetch products with current category filter
  void _fetchProductsWithCategories() {
    // Always fetch products - include categoryIds only if list is not empty
    // ignore: avoid_print
    print(
        '[CatalogPage] Fetching products with categoryIds: ${_selectedCategoryIds.isEmpty ? 'null (all products)' : _selectedCategoryIds}');
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

  double _categoriesHeight = 180; // Initial estimate
  final GlobalKey _categoriesKey = GlobalKey();

  @override
  void dispose() {
    _offersPageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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

  void _measureCategories() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _categoriesKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.size.height != _categoriesHeight) {
          setState(() {
            _categoriesHeight = box.size.height;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _measureCategories();
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
              // Trigger measurement after state change
              _measureCategories();
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
        child: Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Trigger refresh for both categories and catalog
                _categoriesBloc.add(CategoriesLoadEvent());
                _catalogBloc.add(CatalogLoadEvent(
                  categoryIds: _selectedCategoryIds.isEmpty
                      ? null
                      : _selectedCategoryIds,
                  timestamp: DateTime.now(),
                ));
                // Wait a bit to ensure the loading state is processed
                await Future.delayed(const Duration(seconds: 1));
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 20, left: 28, right: 28, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder<AppLocale>(
                            valueListenable: AppLanguage.localeNotifier,
                            builder: (context, locale, _) {
                              return Row(
                                children: [
                                  Text(AppLanguage.welcomeTo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(fontSize: 24)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                      height: 32,
                                      width: 116,
                                      child: Image.asset(
                                          'assets/logo/full_logo.png',
                                          width: 116,
                                          height: 116)),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          // Search + notifications
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppSearchbar(
                                    onChanged: (value) => context
                                        .read<CatalogBloc>()
                                        .add(CatalogLoadEvent(query: value)),
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
                        ],
                      ),
                    ),
                  ),
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    floating: true,
                    snap: true,
                    pinned: false,
                    toolbarHeight: 0,
                    collapsedHeight: 0,
                    expandedHeight: _categoriesHeight,
                    flexibleSpace: FlexibleSpaceBar(
                      background: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Container(
                          key: _categoriesKey,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              // Categories header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLanguage.categories,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                  InkWell(
                                    onTap: () =>
                                        context.push('/filters/categories'),
                                    child: Text(AppLanguage.viewAll,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: AppColors.hint,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    AppColors.hint)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Categories grid
                              BlocBuilder<CategoriesBloc, CategoriesState>(
                                  builder: (context, state) {
                                if (state is CategoriesLoading) {
                                  return categoriesSkeletonGrid(
                                      count: 6,
                                      crossAxisCount: 3,
                                      itemHeight: 90);
                                }
                                if (state is CategoriesError) {
                                  return const SizedBox.shrink();
                                }
                                if (state is CategoriesLoaded) {
                                  const maxCategoriesToShow = 9;
                                  final hasMore =
                                      state.items.length > maxCategoriesToShow;
                                  final displayCategories = hasMore
                                      ? state.items
                                          .take(maxCategoriesToShow)
                                          .toList()
                                      : state.items;

                                  return CategoryGrid(
                                    categories: displayCategories,
                                    crossAxisCount: 3,
                                    itemHeight: 90,
                                    showMoreIndicator: hasMore,
                                    onSelectionChanged: (selectedIds) {
                                      _updateSelectedCategories(selectedIds);
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                              const SizedBox(height: 12), // Bottom padding
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  BlocBuilder<CatalogBloc, CatalogState>(
                      bloc: _catalogBloc,
                      builder: (context, state) {
                        // Debug logging
                        // ignore: avoid_print
                        print(
                            '🖼️ [CatalogPage] BlocBuilder rebuild - state: ${state.runtimeType}');

                        final isLoading = state is CatalogLoading;
                        final isLoadingMore = state is CatalogLoadingMore;

                        if (state is CatalogError) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Text(
                                AppLanguage.noProductsFound,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.hint),
                              ),
                            ),
                          );
                        }

                        List<Product> products = [];
                        bool hasMore = false;

                        if (state is CatalogLoadingMore) {
                          products = state.products;
                          hasMore = state.hasMore;
                        } else if (state is CatalogLoaded) {
                          products = state.products;
                          hasMore = state.hasMore;
                        } else if (isLoading) {
                          return ProductsList(
                            products: [],
                            isLoading: true,
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            asSliver: true,
                          );
                        }

                        if (products.isEmpty && !isLoading) {
                          return SliverFillRemaining(
                            child: Center(
                                child: Text(AppLanguage.noProductsFound,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.hint))),
                          );
                        }

                        return ProductsList(
                          key: const PageStorageKey('products_list'),
                          products: products,
                          isLoading: isLoadingMore,
                          hasMore: hasMore,
                          // onLoadMore is handled by _onScroll in CustomScrollView
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          asSliver: true,
                        );
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
