import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';
import '../bloc/categories_state.dart';
import '../../domain/entities/category.dart';
import 'subcategories_page.dart';
import 'package:amerli_app/core/error/error_handler.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final Set<int> _selected = <int>{};

  @override
  void initState() {
    super.initState();
    // Trigger load
    context.read<CategoriesBloc>().add(CategoriesLoadEvent());
  }

  void _toggle(Category c) {
    setState(() {
      if (_selected.contains(c.id)) _selected.remove(c.id);
      else _selected.add(c.id);
    });
    // Optionally, trigger a catalog filter load for immediate feedback
    try {
      final catalogBloc = context.read<CatalogBloc>();
      // Fire a simple query by category name (backend may need different shape)
      catalogBloc.add(CatalogLoadEvent(query: c.name));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesBloc, CategoriesState>(
      listener: (context, state) {
        if (state is CategoriesError) {
          ErrorHandler.showError(context, state.message);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(gradient: AppColors.gradientFromScheme(Theme.of(context).colorScheme)),
          child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Back button like product details
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/back_arrow.svg',
                          width: 14,
                          height: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                          placeholderBuilder: (context) => Icon(
                            Icons.arrow_back,
                            size: 14,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Categorie', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        final state = context.read<CategoriesBloc>().state;
                        if (state is CategoriesLoaded) {
                          setState(() {
                            if (_selected.length == state.items.length) _selected.clear();
                            else _selected.addAll(state.items.map((e) => e.id));
                          });
                          final selectedNames = state.items.where((e) => _selected.contains(e.id)).map((e) => e.name).join(',');
                          try {
                            context.read<CatalogBloc>().add(CatalogLoadEvent(query: selectedNames));
                          } catch (_) {}
                        }
                      },
                      child: const Text('Tout'),
                    ),
                  ],
                ),
                Expanded(
                  child: BlocBuilder<CategoriesBloc, CategoriesState>(builder: (context, state) {
                    if (state is CategoriesLoading) return const Center(child: CircularProgressIndicator());
                    if (state is CategoriesLoaded) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: state.items.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.neutralLight300),
                              itemBuilder: (context, index) {
                                final Category c = state.items[index];
                                final selected = _selected.contains(c.id);
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
                                  title: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                                    child: Text(c.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  ),
                                  trailing: c.subcategories.isNotEmpty
                                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                                          Transform.scale(
                                            scale: 0.9,
                                            child: Checkbox(
                                              value: selected,
                                              onChanged: (_) => _toggle(c),
                                              shape: const CircleBorder(),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.chevron_right),
                                        ])
                                      : Transform.scale(
                                          scale: 0.9,
                                          child: Checkbox(
                                            value: selected,
                                            onChanged: (_) => _toggle(c),
                                            shape: const CircleBorder(),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                  onTap: () {
                                    if (c.subcategories.isNotEmpty) {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SubcategoriesPage(parent: c)));
                                    } else {
                                      _toggle(c);
                                    }
                                  },
                                );
                              },
                            ),
                          ),

                          // Apply button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  final state = context.read<CategoriesBloc>().state;
                                  if (state is CategoriesLoaded) {
                                    final selectedNames = state.items.where((e) => _selected.contains(e.id)).map((e) => e.name).join(',');
                                    try {
                                      context.read<CatalogBloc>().add(CatalogLoadEvent(query: selectedNames));
                                    } catch (_) {}
                                  }
                                  Navigator.of(context).pop();
                                },
                                style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)),
                                child: const Text('Appliquer les filtres'),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (state is CategoriesError) return const Center(child: Text('Aucune catégorie trouvée'));
                    return const SizedBox.shrink();
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    ), // Scaffold closing
    ); // BlocListener closing
  }
}
