import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/favorits/app/bloc/favorits_bloc.dart' as fav_feature;
import 'package:amerli_app/features/favorits/app/bloc/favorits_event.dart';
import 'package:amerli_app/features/favorits/app/bloc/favorits_state.dart';
import 'package:amerli_app/features/catalog/app/widgets/products_list.dart';
import 'package:amerli_app/core/config/injection.dart';

class FavoritsPage extends StatelessWidget {
  const FavoritsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<fav_feature.FavoritsBloc>(
      create: (_) => sl<fav_feature.FavoritsBloc>()..add(FavoritsLoadEvent()),
      child: const _FavoritsView(),
    );
  }
}

class _FavoritsView extends StatelessWidget {
  const _FavoritsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 28, right: 28),
        child: BlocBuilder<fav_feature.FavoritsBloc, FavoritsState>(
          builder: (context, state) {
            if (state is FavoritsLoading) {
              return const ProductsList(products: [], isLoading: true);
            }
            if (state is FavoritsLoaded) {
              return ProductsList(products: state.products);
            }
            if (state is FavoritsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}


