import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amerli_app/widgets/searchbar.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import '../bloc/admin_categories_bloc.dart';
import '../bloc/admin_categories_event.dart';
import '../bloc/admin_categories_state.dart';
import '../../domain/entities/category.dart';

import 'package:amerli_app/core/utils/top_toast.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<AdminCategoriesBloc>()
        .add(const AdminCategoriesLoadEvent(page: 1, limit: 20));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AdminCategoriesBloc>().state;
      if (state is AdminCategoriesLoaded &&
          state.hasMore &&
          !state.isLoadingMore) {
        context.read<AdminCategoriesBloc>().add(
            AdminCategoriesLoadEvent(page: state.currentPage + 1, limit: 20));
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
    context
        .read<AdminCategoriesBloc>()
        .add(AdminCategoriesLoadEvent(query: query, page: 1, limit: 20));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) =>
          BlocListener<AdminCategoriesBloc, AdminCategoriesState>(
        listener: (context, state) {
          if (state is AdminCategoriesError) {
            TopToast.show(context, state.message, isError: true);
          } else if (state is AdminCategoriesOperationSuccess) {
            TopToast.show(context, state.message, isError: false);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                            matchTextDirection: true,
                            color: Theme.of(context).colorScheme.onPrimary,
                            placeholderBuilder: (context) => Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(AppLanguage.manageCategories,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Search + Add compact row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                            child: SizedBox(
                                height: 40,
                                child: AppSearchbar(
                                    onChanged: _onSearch, showFilter: false))),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              context.push('/admin/categories/add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            minimumSize: const Size(0, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(AppLanguage.add,
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<AdminCategoriesBloc>().add(
                          const AdminCategoriesLoadEvent(page: 1, limit: 20));
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: BlocBuilder<AdminCategoriesBloc,
                          AdminCategoriesState>(builder: (context, state) {
                        if (state is AdminCategoriesLoading) {
                          return const SizedBox(
                              height: 400,
                              child:
                                  Center(child: CircularProgressIndicator()));
                        }
                        if (state is AdminCategoriesError) {
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
                                    context.read<AdminCategoriesBloc>().add(
                                        const AdminCategoriesLoadEvent(
                                            page: 1, limit: 20));
                                  },
                                  child: Text(AppLanguage.retry),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is AdminCategoriesLoaded) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCategoriesTable(state),
                                  if (state.isLoadingMore)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    ),
                                  const SizedBox(height: 24),
                                  Text(AppLanguage.subcategories,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  const SizedBox(height: 12),
                                  _buildSubCategoriesTable(state),
                                  const SizedBox(height: 100),
                                ]),
                          );
                        }
                        return SizedBox(
                            height: 400,
                            child: Center(
                                child: Text(AppLanguage.noDataAvailable)));
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesTable(AdminCategoriesLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        border:
            Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: Row(children: [
              const SizedBox(width: 8),
              Expanded(
                  flex: 4,
                  child: Text(AppLanguage.category,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black))),
              SizedBox(
                  width: 44,
                  child: Text(AppLanguage.actions,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black))),
            ]),
          ),

          // Category Rows
          ...state.filteredCategories.map((category) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(children: [
                  const SizedBox(width: 8),

                  // Category info
                  Expanded(
                    flex: 4,
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: category.imageUrl != null &&
                                category.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(category.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                        size: 16)))
                            : Icon(Icons.category,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category.name,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              Text(category.id,
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade600)),
                            ]),
                      ),
                    ]),
                  ),

                  // Actions (SVG icons)
                  SizedBox(
                    width: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => context.push(
                              '/admin/categories/edit/${category.id}',
                              extra: category),
                          child: SvgPicture.asset(
                            'assets/icons/small_edit.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                                AppColors.brandDeep, BlendMode.srcIn),
                            placeholderBuilder: (c) => Icon(Icons.edit,
                                size: 16, color: AppColors.brandDeep),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _onDeleteDialog(category.id),
                          child: SvgPicture.asset(
                            'assets/icons/delete.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                                Colors.red, BlendMode.srcIn),
                            placeholderBuilder: (c) =>
                                Icon(Icons.delete, size: 16, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12)),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesTable(AdminCategoriesLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary, width: 1)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [
            const SizedBox(width: 8),
            Expanded(
                flex: 3,
                child: Text(AppLanguage.subcategory,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black))),
            Expanded(
                flex: 3,
                child: Text(AppLanguage.mainCategory,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black))),
            SizedBox(
                width: 50,
                child: Text(AppLanguage.actions,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black))),
          ]),
        ),

        // Rows
        ...state.subCategories.map((subCategory) {
          Category? parent;
          try {
            parent = state.categories
                .firstWhere((c) => c.id == subCategory.categoryId);
          } catch (_) {
            parent = null;
          }

          return Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(children: [
                const SizedBox(width: 8),

                // Subcategory info with image
                Expanded(
                  flex: 3,
                  child: Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: subCategory.imageUrl != null &&
                              subCategory.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(subCategory.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey.shade400,
                                      size: 16)))
                          : Icon(Icons.category,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(subCategory.name,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ),

                // Parent category with image
                Expanded(
                  flex: 3,
                  child: Row(children: [
                    Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6)),
                        child: (subCategory.parentImageUrl != null &&
                                subCategory.parentImageUrl!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                    subCategory.parentImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Icon(
                                        Icons.image_not_supported,
                                        size: 16,
                                        color: Colors.grey.shade400)))
                            : (parent != null &&
                                    parent.imageUrl != null &&
                                    parent.imageUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(parent.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Icon(
                                            Icons.image_not_supported,
                                            size: 16,
                                            color: Colors.grey.shade400)))
                                : Icon(Icons.category,
                                    size: 16, color: Colors.grey.shade600)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(subCategory.categoryName,
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                  ]),
                ),

                // Actions
                SizedBox(
                  width: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => context.push(
                            '/admin/subcategories/edit/${subCategory.id}',
                            extra: Category(
                              id: subCategory.id,
                              name: subCategory.name,
                              description: '',
                              imageUrl: subCategory.imageUrl,
                              productCount: subCategory.productCount,
                              createdAt: subCategory.createdAt,
                              updatedAt: subCategory.updatedAt,
                              parentId: subCategory.categoryId,
                            )),
                        child: SvgPicture.asset(
                          'assets/icons/small_edit.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                              AppColors.brandDeep, BlendMode.srcIn),
                          placeholderBuilder: (c) => Icon(Icons.edit,
                              size: 16, color: AppColors.brandDeep),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _onDeleteSubDialog(subCategory.id),
                        child: SvgPicture.asset(
                          'assets/icons/delete.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                              Colors.red, BlendMode.srcIn),
                          placeholderBuilder: (c) =>
                              Icon(Icons.delete, size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12)),
          ]);
        }),
      ]),
    );
  }

  void _onDeleteDialog(String categoryId) {
    final bloc = context.read<AdminCategoriesBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLanguage.delete),
        content: Text(AppLanguage.deleteCategoryConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLanguage.cancel)),
          TextButton(
            onPressed: () {
              bloc.add(AdminCategoriesDeleteEvent(categoryId));
              Navigator.pop(context);
            },
            child: Text(AppLanguage.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onDeleteSubDialog(String id) {
    final bloc = context.read<AdminCategoriesBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLanguage.delete),
        content: Text(AppLanguage.deleteSubcategoryConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLanguage.cancel)),
          TextButton(
            onPressed: () {
              bloc.add(AdminSubCategoriesDeleteEvent(id));
              Navigator.pop(context);
            },
            child: Text(AppLanguage.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
