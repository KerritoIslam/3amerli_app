import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:go_router/go_router.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import 'package:amerli_app/core/config/injection.dart';
import 'package:amerli_app/features/admin/products/app/bloc/admin_products_bloc.dart';
import 'package:amerli_app/features/admin/products/app/bloc/admin_products_event.dart';
import 'package:amerli_app/features/admin/products/app/bloc/admin_products_state.dart';

class FiltersPage extends StatefulWidget {
  final bool isAdminMode;

  const FiltersPage({super.key, this.isAdminMode = false});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  final Set<int> _selectedCategoryIds = <int>{};
  final Set<int> _selectedBrandIds = <int>{};
  bool _isApplying = false;

  Future<void> _applyFilters() async {
    // Show loading state
    setState(() {
      _isApplying = true;
    });

    if (widget.isAdminMode) {
      // Admin mode: use AdminProductsBloc
      final adminBloc = sl<AdminProductsBloc>();

      // Debug: Log the filters being applied
      // ignore: avoid_print
      print(
          '🔍 [FiltersPage:Admin] Applying filters - categoryIds: ${_selectedCategoryIds.isEmpty ? 'none' : _selectedCategoryIds}, brandIds: ${_selectedBrandIds.isEmpty ? 'none' : _selectedBrandIds}');

      // Apply filters with selected IDs
      adminBloc.add(AdminProductsLoadEvent(
        categoryIds:
            _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds.toList(),
        brandIds: _selectedBrandIds.isEmpty ? null : _selectedBrandIds.toList(),
      ));

      // Wait for the bloc to emit loaded or error state
      await adminBloc.stream.firstWhere(
        (state) => state is AdminProductsLoaded || state is AdminProductsError,
        orElse: () => adminBloc.state,
      );

      // Debug: Log bloc state
      // ignore: avoid_print
      print(
          '🔍 [FiltersPage:Admin] Filters applied, state: ${adminBloc.state.runtimeType}');
    } else {
      // Catalog mode: use CatalogBloc
      final catalogBloc = sl<CatalogBloc>();

      // Debug: Log the filters being applied
      // ignore: avoid_print
      print(
          '🔍 [FiltersPage:Catalog] Applying filters - categoryIds: ${_selectedCategoryIds.isEmpty ? 'none' : _selectedCategoryIds}, brandIds: ${_selectedBrandIds.isEmpty ? 'none' : _selectedBrandIds}');

      // Apply filters with selected IDs
      catalogBloc.add(CatalogLoadEvent(
        categoryIds:
            _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds.toList(),
        brandIds: _selectedBrandIds.isEmpty ? null : _selectedBrandIds.toList(),
      ));

      // Wait for the bloc to emit CatalogLoaded or CatalogError state
      await catalogBloc.stream.firstWhere(
        (state) => state is CatalogLoaded || state is CatalogError,
        orElse: () => catalogBloc.state,
      );

      // Debug: Log bloc state
      // ignore: avoid_print
      print(
          '🔍 [FiltersPage:Catalog] Filters applied, state: ${catalogBloc.state.runtimeType}');
    }

    // Hide loading and pop
    if (mounted) {
      setState(() {
        _isApplying = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientFromScheme(Theme.of(context).colorScheme),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Back button styled like ProductDetailsPage (smaller)
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/back_arrow.svg',
                          width: 14,
                          height: 14,
                          matchTextDirection: true,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onPrimary,
                              BlendMode.srcIn),
                          placeholderBuilder: (context) => Icon(
                            Icons.arrow_back,
                            size: 14,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Text(AppLanguage.filter,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 24),
                ListTile(
                  title: Text(
                    AppLanguage.category,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: _selectedCategoryIds.isNotEmpty
                      ? Text(
                          '${_selectedCategoryIds.length} ${AppLanguage.selected}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        )
                      : null,
                  trailing: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                  ),
                  enabled: !_isApplying,
                  onTap: () async {
                    // Navigate to categories page and wait for result
                    final result =
                        await context.push<Set<int>>('/filters/categories');
                    if (result != null) {
                      setState(() {
                        _selectedCategoryIds.clear();
                        _selectedCategoryIds.addAll(result);
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    AppLanguage.brand,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: _selectedBrandIds.isNotEmpty
                      ? Text(
                          '${_selectedBrandIds.length} ${AppLanguage.selected}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        )
                      : null,
                  trailing: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                  ),
                  enabled: !_isApplying,
                  onTap: () async {
                    // Navigate to brands page and wait for result
                    final result =
                        await context.push<Set<int>>('/filters/brands');
                    if (result != null) {
                      setState(() {
                        _selectedBrandIds.clear();
                        _selectedBrandIds.addAll(result);
                      });
                    }
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isApplying ? null : _applyFilters,
                    style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _isApplying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(AppLanguage.apply),
                  ),
                ),
                const SizedBox(
                    height:
                        80), // Add spacing to raise button above bottom nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
