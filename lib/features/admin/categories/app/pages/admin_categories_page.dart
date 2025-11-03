import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/core/error/error_handler.dart';
import '../bloc/admin_categories_bloc.dart';
import '../bloc/admin_categories_event.dart';
import '../bloc/admin_categories_state.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    context.read<AdminCategoriesBloc>().add(const AdminCategoriesLoadEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<AdminCategoriesBloc>().add(AdminCategoriesLoadEvent(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminCategoriesBloc, AdminCategoriesState>(
      listener: (context, state) {
        if (state is AdminCategoriesError) {
          ErrorHandler.showError(context, state.message);
        } else if (state is AdminCategoriesOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.brandDeep,
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
                  children: [
                    Expanded(
                      child: Text(
                        'Gérer les catégories',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Search and Add Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearch,
                          decoration: InputDecoration(
                            hintText: 'Rechercher une catégorie…',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => context.push('/admin/categories/add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        '+ Ajouter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: BlocBuilder<AdminCategoriesBloc, AdminCategoriesState>(
                  builder: (context, state) {
                    if (state is AdminCategoriesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AdminCategoriesLoaded) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Categories Table
                            _buildCategoriesTable(state),

                            const SizedBox(height: 24),

                            // Subcategories Section
                            const Text(
                              'Sous-catégories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildSubCategoriesTable(state),

                            const SizedBox(height: 100), // Bottom nav padding
                          ],
                        ),
                      );
                    }

                    return const Center(
                      child: Text('Aucune donnée disponible'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesTable(AdminCategoriesLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  width: 40,
                  child: Checkbox(
                    value: _selectedIds.length == state.filteredCategories.length &&
                        _selectedIds.isNotEmpty,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds.addAll(
                            state.filteredCategories.map((cat) => cat.id),
                          );
                        } else {
                          _selectedIds.clear();
                        }
                      });
                    },
                    activeColor: AppColors.brandDeep,
                  ),
                ),
                const Expanded(
                  flex: 4,
                  child: Text(
                    'Catégorie',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Produits',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 50,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Rows
          ...state.filteredCategories.map((category) {
            final isSelected = _selectedIds.contains(category.id);
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(category.id);
                            } else {
                              _selectedIds.remove(category.id);
                            }
                          });
                        },
                        activeColor: AppColors.brandDeep,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.category,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  category.id,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '${category.productCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => context.push('/admin/categories/edit/${category.id}'),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showDeleteDialog(category.id),
                            child: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesTable(AdminCategoriesLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Sous-catégorie',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Catégorie principale',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subcategory Rows
          ...state.subCategories.map((subCategory) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        subCategory.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        subCategory.categoryName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showDeleteSubCategoryDialog(subCategory.id),
                            child: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showDeleteDialog(String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette catégorie ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminCategoriesBloc>().add(
                    AdminCategoriesDeleteEvent(categoryId),
                  );
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteSubCategoryDialog(String subCategoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la sous-catégorie'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette sous-catégorie ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminCategoriesBloc>().add(
                    AdminSubCategoriesDeleteEvent(subCategoryId),
                  );
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
