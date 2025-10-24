// skeleton import removed (not used in this page anymore)
import 'package:amerli_app/features/catalog/app/bloc/categories_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/categories_state.dart';
import 'package:amerli_app/features/catalog/app/bloc/categories_event.dart';
import 'package:amerli_app/features/catalog/app/widgets/category_grid.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/favorits/app/bloc/favorits_bloc.dart' as fav_feature;
import 'package:amerli_app/features/favorits/app/bloc/favorits_event.dart';
import 'package:amerli_app/features/favorits/app/bloc/favorits_state.dart';
import 'package:amerli_app/features/catalog/app/widgets/products_list.dart';
import 'package:amerli_app/core/config/injection.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Catégories', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Voir tout', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint, decoration: TextDecoration.underline ,decorationColor: AppColors.hint)),
                ],
              ),

              const SizedBox(height: 12),

              // Categories grid
              BlocBuilder<CategoriesBloc, CategoriesState>(builder: (context, state) {
                if (state is CategoriesLoading) {
                  return categoriesSkeletonGrid(count: 6, crossAxisCount: 3, itemHeight: 90);
                }

                if (state is CategoriesError) return Center(child: Text('Categories error: ${state.message}'));
                if (state is CategoriesLoaded) return CategoryGrid(categories: state.items, crossAxisCount: 3, itemHeight: 90, onTap: (cat) {
                  // Reload favorites filtered by category
                  context.read<fav_feature.FavoritsBloc>().add(FavoritsLoadEvent());
                });
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0, right: 12.0),
                  child: BlocBuilder<fav_feature.FavoritsBloc, FavoritsState>(
                    builder: (context, state) {
                      if (state is FavoritsLoading) {
                        return const ProductsList(products: [], isLoading: true);
                      }
                      if (state is FavoritsLoaded) {
                        if (state.products.isEmpty) {
                          return Center(child: Text('Aucun favori trouvé', style: Theme.of(context).textTheme.bodyLarge));
                        }
                        return ProductsList(products: state.products);
                      }
                      if (state is FavoritsError) {
                        return Center(child: Text('Error: ${state.message}'));
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
    );
  }
}


