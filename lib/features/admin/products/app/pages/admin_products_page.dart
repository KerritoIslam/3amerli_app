import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_products_bloc.dart';
import '../bloc/admin_products_event.dart';
import '../bloc/admin_products_state.dart';
import '../../domain/entities/product.dart';
import 'package:amerli_app/core/error/error_handler.dart';
import 'package:amerli_app/widgets/searchbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import '../../../brands/app/pages/admin_brands_page.dart';
import 'package:amerli_app/features/catalog/app/pages/filters_page.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

import 'package:amerli_app/core/utils/top_toast.dart';
import 'package:amerli_app/core/utils/csv_export_helper.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedProductIds = {};
  String? _selectedCategory;

  // Track selected filters
  final Set<int> _selectedCategoryIds = {};
  final Set<int> _selectedBrandIds = {};

  late final AdminProductsBloc _productsBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _productsBloc = context.read<AdminProductsBloc>();
    _productsBloc.add(AdminProductsLoadEvent(page: 1, limit: 20));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _productsBloc.state;
      if (state is AdminProductsLoaded &&
          state.hasMore &&
          !state.isLoadingMore) {
        _productsBloc.add(AdminProductsLoadEvent(
          query: state.currentQuery,
          category: state.currentCategory,
          categoryIds: _selectedCategoryIds.isEmpty
              ? null
              : _selectedCategoryIds.toList(),
          brandIds:
              _selectedBrandIds.isEmpty ? null : _selectedBrandIds.toList(),
          page: state.currentPage + 1,
          limit: 20,
        ));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _productsBloc.add(
      AdminProductsLoadEvent(
        query: query,
        category: _selectedCategory,
        categoryIds:
            _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds.toList(),
        brandIds: _selectedBrandIds.isEmpty ? null : _selectedBrandIds.toList(),
        page: 1,
        limit: 20,
      ),
    );
  }

  void _openFilters() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FiltersPage(isAdminMode: true),
      ),
    );
  }

  void _onDeleteProduct(String id) {
    final bloc = context.read<AdminProductsBloc>();
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<AppLocale>(
        valueListenable: AppLanguage.localeNotifier,
        builder: (context, locale, _) => AlertDialog(
          title: Text(AppLanguage.deleteProduct),
          content: Text(AppLanguage.deleteProductConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLanguage.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                bloc.add(AdminProductsDeleteEvent(id));
              },
              child: Text(
                AppLanguage.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDeleteSelected() {
    if (_selectedProductIds.isEmpty) return;
    final bloc = context.read<AdminProductsBloc>();

    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<AppLocale>(
        valueListenable: AppLanguage.localeNotifier,
        builder: (context, locale, _) => AlertDialog(
          title: Text(AppLanguage.deleteProducts),
          content: Text(
              '${AppLanguage.deleteProductsConfirm} (${_selectedProductIds.length})'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLanguage.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                bloc.add(
                  AdminProductsDeleteMultipleEvent(
                      _selectedProductIds.toList()),
                );
                setState(() {
                  _selectedProductIds.clear();
                });
              },
              child: Text(
                AppLanguage.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) =>
          BlocListener<AdminProductsBloc, AdminProductsState>(
        listener: (context, state) {
          if (state is AdminProductsError) {
            TopToast.show(context, state.message, isError: true);
          }
          if (state is AdminProductsOperationSuccess) {
            TopToast.show(context, state.message, isError: false);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Text(
                          AppLanguage.manageProducts,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Builder(
                        builder: (ctx) => InkWell(
                          onTap: () => _showOptionsMenu(ctx),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.more_horiz,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search and Add Product
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: AppSearchbar(
                            controller: _searchController,
                            onChanged: _onSearch,
                            showFilter: true,
                            onFilterTap: _openFilters,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/admin/products/add');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLanguage.add,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_selectedProductIds.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _onDeleteSelected,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            elevation: 0,
                          ),
                          child: Text(
                            '${AppLanguage.delete} (${_selectedProductIds.length})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Products Table
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<AdminProductsBloc>()
                          .add(AdminProductsLoadEvent(page: 1, limit: 20));
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: BlocBuilder<AdminProductsBloc, AdminProductsState>(
                        builder: (context, state) {
                          if (state is AdminProductsLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (state is AdminProductsError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Icon(Icons.error_outline,
                                      size: 48, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(state.message,
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<AdminProductsBloc>().add(
                                          AdminProductsLoadEvent(
                                              page: 1, limit: 20));
                                    },
                                    child: Text(AppLanguage.retry),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state is AdminProductsLoaded) {
                            if (state.products.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppLanguage.noProductsFound,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Header
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Checkbox(
                                                value: _selectedProductIds
                                                        .length ==
                                                    state.products.length,
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      _selectedProductIds
                                                          .addAll(state.products
                                                              .map(
                                                                  (p) => p.id));
                                                    } else {
                                                      _selectedProductIds
                                                          .clear();
                                                    }
                                                  });
                                                },
                                                activeColor:
                                                    AppColors.brandDeep,
                                                shape: const CircleBorder(),
                                                side: BorderSide(
                                                    color:
                                                        Colors.grey.shade400),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 40,
                                              child: Text(
                                                AppLanguage.image,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                AppLanguage.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                AppLanguage.price,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                AppLanguage.stock,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 40,
                                              child: Text(
                                                AppLanguage.actions,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // List
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: state.products.length,
                                        separatorBuilder: (context, index) =>
                                            Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.12),
                                        ),
                                        itemBuilder: (context, index) {
                                          final product = state.products[index];
                                          final isSelected = _selectedProductIds
                                              .contains(product.id);
                                          return _ProductRow(
                                            product: product,
                                            isSelected: isSelected,
                                            onSelectChanged: (value) {
                                              setState(() {
                                                if (value == true) {
                                                  _selectedProductIds
                                                      .add(product.id);
                                                } else {
                                                  _selectedProductIds
                                                      .remove(product.id);
                                                }
                                              });
                                            },
                                            onEdit: () {
                                              context.push(
                                                  '/admin/products/edit/${product.id}');
                                            },
                                            onDelete: () {
                                              _onDeleteProduct(product.id);
                                            },
                                          );
                                        },
                                      ),
                                      if (state.isLoadingMore)
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 80),
                              ],
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onExportCSV() async {
    final state = _productsBloc.state;
    if (state is! AdminProductsLoaded || state.products.isEmpty) {
      TopToast.show(context, AppLanguage.noProductsFound, isError: true);
      return;
    }

    try {
      final headers = [
        'ID',
        'Name',
        'Price',
        'Stock Status',
        'Category',
        'Brand'
      ];

      final data = state.products.map((p) {
        return [
          p.id,
          p.name,
          p.pricePerLot,
          p.stockStatus,
          p.category,
          p.brand,
        ];
      }).toList();

      await CsvExportHelper.exportToCsv(
        fileName: 'products_export_${DateTime.now().millisecondsSinceEpoch}',
        headers: headers,
        data: data,
      );
    } catch (e) {
      TopToast.show(context, AppLanguage.csvExportError, isError: true);
    }
  }

  void _showOptionsMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx +
            button.size.width -
            183, // Position to align right edge of menu with button
        offset.dy + button.size.height + 8, // 8px below the button
        offset.dx + button.size.width,
        offset.dy + button.size.height + 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      constraints: const BoxConstraints(
        minWidth: 183,
        maxWidth: 183,
        minHeight: 119,
        maxHeight: 119,
      ),
      items: [
        PopupMenuItem(
          height: 37,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {
            Future.delayed(Duration.zero, () {
              context.push('/admin/categories');
            });
          },
          child: Text(
            AppLanguage.manageCategories,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        PopupMenuItem(
          height: 37,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {
            Future.delayed(Duration.zero, () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminBrandsPage()));
            });
          },
          child: Text(
            AppLanguage.manageBrands,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        PopupMenuItem(
          height: 37,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {
            _onExportCSV();
          },
          child: Text(
            AppLanguage.exportProducts,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final ValueChanged<bool?> onSelectChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.product,
    required this.isSelected,
    required this.onSelectChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: isSelected,
              onChanged: onSelectChanged,
              shape: const CircleBorder(),
              activeColor: AppColors.brandDeep,
            ),
          ),
          const SizedBox(width: 6),

          // Product Info
          Expanded(
            flex: 4,
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: product.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            product.images[product.mainImageIndex],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                              size: 16,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey.shade400,
                          size: 16,
                        ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${product.id}',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Price
          Expanded(
            flex: 2,
            child: Text(
              '${product.pricePerLot.toStringAsFixed(2)} DZD',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Stock Status
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status icon and colored text
                if (product.stockStatus.toLowerCase().contains('stock') ||
                    product.stockStatus.toLowerCase().contains('disponible') ||
                    (product.stockStatus.contains('متوفر') &&
                        !product.stockStatus.contains('غير'))) ...[
                  SvgPicture.asset(
                    'assets/icons/bag.svg',
                    width: 12,
                    height: 12,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFA1E3CB), BlendMode.srcIn),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      AppLanguage.inStock,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFA1E3CB),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  SvgPicture.asset(
                    'assets/icons/ruptur.svg',
                    width: 12,
                    height: 12,
                    colorFilter:
                        const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      AppLanguage.outOfStock,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          SizedBox(
            width: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit Button
                InkWell(
                  onTap: onEdit,
                  child: SvgPicture.asset(
                    'assets/icons/small_edit.svg',
                    width: 16,
                    height: 16,
                    colorFilter:
                        ColorFilter.mode(AppColors.brandDeep, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 4),
                // Delete Button
                InkWell(
                  onTap: onDelete,
                  child: SvgPicture.asset(
                    'assets/icons/delete.svg',
                    width: 16,
                    height: 16,
                    colorFilter:
                        const ColorFilter.mode(Colors.red, BlendMode.srcIn),
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
