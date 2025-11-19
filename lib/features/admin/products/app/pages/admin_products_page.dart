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

  @override
  void initState() {
    super.initState();
    _productsBloc = context.read<AdminProductsBloc>();
    _productsBloc.add(AdminProductsLoadEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _productsBloc.add(
          AdminProductsLoadEvent(
            query: query,
            category: _selectedCategory,
            categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds.toList(),
            brandIds: _selectedBrandIds.isEmpty ? null : _selectedBrandIds.toList(),
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
                context.read<AdminProductsBloc>().add(AdminProductsDeleteEvent(id));
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
                context.read<AdminProductsBloc>().add(
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
      builder: (context, locale, _) => BlocListener<AdminProductsBloc, AdminProductsState>(
      listener: (context, state) {
        if (state is AdminProductsError) {
          ErrorHandler.showError(context, state.message);
        }
        if (state is AdminProductsOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: BlocBuilder<AdminProductsBloc, AdminProductsState>(
                        bloc: _productsBloc,
                        builder: (context, state) {
                          var countText = '';
                          if (state is AdminProductsLoaded) countText = ' (${state.products.length})';
                          return Text(
                            '${AppLanguage.products}$countText',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Builder(
                        builder: (buttonContext) => InkWell(
                          onTap: () => _showOptionsMenu(buttonContext),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.more_horiz,
                              color: Theme.of(context).colorScheme.primary,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search and Action Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Search Field
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: AppSearchbar(
                          onChanged: _onSearch,
                          onFilterTap: _openFilters,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                   
                    // Add Button
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/admin/products/add');
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppLanguage.add),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Delete Selected Button (visible when items are selected)
              if (_selectedProductIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        '${_selectedProductIds.length} ${AppLanguage.selected}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _onDeleteSelected,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: Text(
                          AppLanguage.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Product Table
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<AdminProductsBloc, AdminProductsState>(
                    bloc: _productsBloc,
                    builder: (context, state) {
                      // Debug logging
                      print('🖼️ [AdminProductsPage] BlocBuilder rebuild - state: ${state.runtimeType}');
                      
                      if (state is AdminProductsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is AdminProductsLoaded) {
                        print('🖼️ [AdminProductsPage] Displaying ${state.products.length} products');
                        
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

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Select All Checkbox
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _selectedProductIds.length ==
                                          state.products.length,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedProductIds.addAll(
                                              state.products.map((p) => p.id),
                                            );
                                          } else {
                                            _selectedProductIds.clear();
                                          }
                                        });
                                      },
                                      shape: const CircleBorder(),
                                      activeColor: AppColors.brandDeep,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      AppLanguage.product,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      AppLanguage.price,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      AppLanguage.stock,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      AppLanguage.actions,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Product List
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.products.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                ),
                                itemBuilder: (context, index) {
                                  final product = state.products[index];
                                  final isSelected =
                                      _selectedProductIds.contains(product.id);

                                  return _ProductRow(
                                    product: product,
                                    isSelected: isSelected,
                                    onSelectChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedProductIds.add(product.id);
                                        } else {
                                          _selectedProductIds
                                              .remove(product.id);
                                        }
                                      });
                                    },
                                    onEdit: () {
                                      context.push(
                                        '/admin/products/edit/${product.id}',
                                      );
                                    },
                                    onDelete: () => _onDeleteProduct(product.id),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
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

  

  void _showOptionsMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + button.size.width - 183, // Position to align right edge of menu with button
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
        minHeight: 152,
        maxHeight: 152,
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
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminBrandsPage()));
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
            // TODO: Implement export functionality
          },
          child: Text(
            AppLanguage.exportProducts,
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
            // TODO: Implement settings functionality
          },
          child: Text(
            AppLanguage.settings,
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
                // Status icon and colored text (use svg icons and brand color for "En stock")
                if (product.stockStatus.toLowerCase() == 'en stock') ...[
                  SvgPicture.asset(
                    'assets/icons/bag.svg',
                    width: 12,
                    height: 12,
                    color: const Color(0xFFA1E3CB),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      product.stockStatus,
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
                    color: Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      product.stockStatus,
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
                      color: AppColors.brandDeep,
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
                    color: Colors.red,
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

