import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amerli_app/core/error/error_handler.dart';
import 'package:amerli_app/widgets/searchbar.dart';
import '../bloc/admin_categories_bloc.dart';
import '../bloc/admin_categories_event.dart';
import '../bloc/admin_categories_state.dart';
import '../../domain/entities/category.dart';
class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final Set<String> _selectedSubIds = {};

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
            SnackBar(content: Text(state.message), backgroundColor: AppColors.brandDeep),
          );
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
                          color: Theme.of(context).colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/back_arrow.svg',
                          width: 16,
                          height: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                          placeholderBuilder: (context) => Icon(Icons.arrow_back, size: 16, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Gérer les catégories', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center),
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
                      Expanded(child: SizedBox(height: 40, child: AppSearchbar(onChanged: _onSearch))),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.push('/admin/categories/add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Ajouter', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: BlocBuilder<AdminCategoriesBloc, AdminCategoriesState>(builder: (context, state) {
                  if (state is AdminCategoriesLoading) return const Center(child: CircularProgressIndicator());
                  if (state is AdminCategoriesLoaded) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildCategoriesTable(state),
                        const SizedBox(height: 24),
                        const Text('Sous-catégories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 12),
                        _buildSubCategoriesTable(state),
                        const SizedBox(height: 100),
                      ]),
                    );
                  }
                  return const Center(child: Text('Aucune donnée disponible'));
                }),
              ),
            ],
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
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
            child: Row(children: [
              SizedBox(
                width: 36,
                child: Checkbox(
                  value: _selectedIds.length == state.filteredCategories.length && _selectedIds.isNotEmpty,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.addAll(state.filteredCategories.map((cat) => cat.id));
                      } else {
                        _selectedIds.clear();
                      }
                    });
                  },
                  shape: const CircleBorder(),
                  activeColor: AppColors.brandDeep,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(flex: 4, child: Text('Catégorie', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black))),
              const SizedBox(width: 44, child: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black))),
            ]),
          ),

          // Category Rows
          ...state.filteredCategories.map((category) {
            final isSelected = _selectedIds.contains(category.id);
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(children: [
                  SizedBox(
                    width: 36,
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
                      shape: const CircleBorder(),
                      activeColor: AppColors.brandDeep,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Category info
                  Expanded(
                    flex: 4,
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(category.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 16)))
                            : Icon(Icons.category, color: Theme.of(context).colorScheme.primary, size: 18),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(category.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text(category.id, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
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
                          onTap: () => context.push('/admin/categories/edit/${category.id}'),
                          child: SvgPicture.asset(
                            'assets/icons/small_edit.svg',
                            width: 16,
                            height: 16,
                            color: AppColors.brandDeep,
                            placeholderBuilder: (c) => Icon(Icons.edit, size: 16, color: AppColors.brandDeep),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _onDeleteDialog(category.id),
                          child: SvgPicture.asset(
                            'assets/icons/delete.svg',
                            width: 16,
                            height: 16,
                            color: Colors.red,
                            placeholderBuilder: (c) => Icon(Icons.delete, size: 16, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.primary.withOpacity(0.12)),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesTable(AdminCategoriesLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: [
            SizedBox(width: 36, child: Checkbox(value: _selectedSubIds.length == state.subCategories.length && _selectedSubIds.isNotEmpty, onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedSubIds.addAll(state.subCategories.map((s) => s.id));
                } else {
                  _selectedSubIds.clear();
                }
              });
            }, shape: const CircleBorder(), activeColor: AppColors.brandDeep)),
            const SizedBox(width: 8),
            const Expanded(flex: 3, child: Text('Sous-catégorie', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black))),
            const Expanded(flex: 3, child: Text('Catégorie principale', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black))),
            const SizedBox(width: 50, child: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black))),
          ]),
        ),

        // Rows
        ...state.subCategories.map((subCategory) {
          final isSelected = _selectedSubIds.contains(subCategory.id);

          Category? parent;
          try {
            parent = state.categories.firstWhere((c) => c.id == subCategory.categoryId);
          } catch (_) {
            parent = null;
          }

          return Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(children: [
                SizedBox(width: 36, child: Checkbox(value: isSelected, onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedSubIds.add(subCategory.id);
                    } else {
                      _selectedSubIds.remove(subCategory.id);
                    }
                  });
                }, shape: const CircleBorder(), activeColor: AppColors.brandDeep)),
                const SizedBox(width: 8),

                // Subcategory name
                Expanded(flex: 3, child: Text(subCategory.name, style: const TextStyle(fontSize: 11, color: Colors.black))),

                // Parent category with image
                Expanded(
                  flex: 3,
                  child: Row(children: [
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)), child: parent != null && parent.imageUrl != null && parent.imageUrl!.isNotEmpty ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(parent.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported, size: 16, color: Colors.grey.shade400))) : Icon(Icons.category, size: 16, color: Colors.grey.shade600)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(subCategory.categoryName, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ),

                // Actions
                SizedBox(
                  width: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => context.push('/admin/subcategories/edit/${subCategory.id}'),
                        child: SvgPicture.asset(
                          'assets/icons/small_edit.svg',
                          width: 16,
                          height: 16,
                          color: AppColors.brandDeep,
                          placeholderBuilder: (c) => Icon(Icons.edit, size: 16, color: AppColors.brandDeep),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _onDeleteSubDialog(subCategory.id),
                        child: SvgPicture.asset(
                          'assets/icons/delete.svg',
                          width: 16,
                          height: 16,
                          color: Colors.red,
                          placeholderBuilder: (c) => Icon(Icons.delete, size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.primary.withOpacity(0.12)),
          ]);
        }),
      ]),
    );
  }

  void _onDeleteDialog(String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette catégorie ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              context.read<AdminCategoriesBloc>().add(AdminCategoriesDeleteEvent(categoryId));
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onDeleteSubDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la sous-catégorie'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette sous-catégorie ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              context.read<AdminCategoriesBloc>().add(AdminSubCategoriesDeleteEvent(id));
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
