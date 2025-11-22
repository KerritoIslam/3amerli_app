import 'package:amerli_app/features/catalog/app/bloc/categories_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/categories_state.dart';
import 'package:amerli_app/features/catalog/app/bloc/categories_event.dart';
import 'package:amerli_app/features/catalog/app/widgets/categories_row.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amerli_app/core/ui/skeleton/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/favorits/app/bloc/favorits_bloc.dart'
    as fav_feature;
import 'package:amerli_app/features/favorits/app/bloc/favorits_event.dart';
import 'package:amerli_app/features/favorits/app/bloc/favorits_state.dart';
import 'package:amerli_app/features/catalog/app/widgets/products_list.dart';
import 'package:amerli_app/core/config/injection.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/core/error/error_handler.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

class FavoritsPage extends StatelessWidget {
  const FavoritsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<fav_feature.FavoritsBloc>(
      create: (_) => sl<fav_feature.FavoritsBloc>()..add(FavoritsLoadEvent()),
      child: BlocProvider<CategoriesBloc>(
        create: (_) => sl<CategoriesBloc>()..add(CategoriesLoadEvent()),
        child: BlocProvider<CartBloc>.value(
          value: sl<CartBloc>(),
          child: const _FavoritsView(),
        ),
      ),
    );
  }
}

class _FavoritsView extends StatelessWidget {
  const _FavoritsView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoriesBloc, CategoriesState>(
          listener: (context, state) {
            if (state is CategoriesError) {
              ErrorHandler.showError(context, state.message);
            }
          },
        ),
        BlocListener<fav_feature.FavoritsBloc, FavoritsState>(
          listener: (context, state) {
            if (state is FavoritsError) {
              ErrorHandler.showError(context, state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top app-bar like row: back button + centered title
                // Top app-bar like row: back button + centered title
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
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
                            AppLanguage.favorites,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      // balance spacing with an invisible box same as back button
                      const SizedBox(width: 40, height: 40),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Categories row
                BlocBuilder<CategoriesBloc, CategoriesState>(
                    builder: (context, state) {
                  if (state is CategoriesLoading) {
                    return _categoriesSkeletonRow();
                  }

                  if (state is CategoriesError) {
                    return Center(child: Text(AppLanguage.noCategoriesFound));
                  }
                  if (state is CategoriesLoaded) {
                    return CategoriesRow(
                        categories: state.items,
                        onTap: (cat) {
                          // Reload favorites filtered by category
                          context
                              .read<fav_feature.FavoritsBloc>()
                              .add(FavoritsLoadEvent());
                        });
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 12),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, left: 12.0, right: 12.0),
                    child: BlocBuilder<fav_feature.FavoritsBloc, FavoritsState>(
                      builder: (context, state) {
                        if (state is FavoritsLoading) {
                          return const ProductsList(
                              products: [], isLoading: true);
                        }
                        if (state is FavoritsLoaded) {
                          if (state.products.isEmpty) {
                            return Center(
                                child: Text(AppLanguage.noFavoritesFound,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge));
                          }
                          return ProductsList(products: state.products);
                        }
                        if (state is FavoritsError) {
                          return Center(
                              child: Text(AppLanguage.noFavoritesFound));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ), // Scaffold closing
    ); // MultiBlocListener closing
  }
}

// Horizontal skeleton row used while categories load
Widget _categoriesSkeletonRow() {
  final widths = [80.0, 100.0, 90.0, 70.0, 110.0, 90.0];
  return SizedBox(
    height: 56,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(6, (i) {
          final w = widths[i % widths.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: SkeletonBox(
                width: w, height: 36, borderRadius: BorderRadius.circular(100)),
          );
        }),
      ),
    ),
  );
}
