import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/widgets/searchbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import '../../domain/entities/brand.dart';
import 'add_brand_page.dart';

class AdminBrandsPage extends StatefulWidget {
  const AdminBrandsPage({super.key});

  @override
  State<AdminBrandsPage> createState() => _AdminBrandsPageState();
}

class _AdminBrandsPageState extends State<AdminBrandsPage> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _selected = {};

  bool get _allSelected => _filteredBrands.isNotEmpty && _filteredBrands.every((b) => _selected[b.id] == true);

  void _toggleSelectAll(bool? v) {
    setState(() {
      for (final b in _filteredBrands) {
        _selected[b.id] = v ?? false;
      }
    });
  }

  // initial sample brands (replace with real data source as needed)
  final List<Brand> _brands = List<Brand>.from([
    Brand(id: '1', name: 'Amor Benamor'),
    Brand(id: '2', name: 'Jumbo'),
    Brand(id: '3', name: 'Cevital'),
    Brand(id: '4', name: 'Sup'),
    Brand(id: '5', name: 'Guediila'),
    Brand(id: '6', name: 'Moment'),
    Brand(id: '7', name: 'Soumam'),
  ]);

  String get _search => _searchController.text.trim().toLowerCase();

  List<Brand> get _filteredBrands {
    if (_search.isEmpty) return _brands;
    return _brands.where((b) => b.name.toLowerCase().contains(_search)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddPage({Brand? edit}) async {
    final result = await Navigator.of(context).push<Brand?>(
      MaterialPageRoute(builder: (_) => AddBrandPage(edit: edit)),
    );
    if (result != null) {
      setState(() {
        if (edit != null) {
          // update existing
          final idx = _brands.indexWhere((b) => b.id == edit.id);
          if (idx != -1) _brands[idx] = result;
        } else {
          // add new
          _brands.insert(0, result);
        }
      });
    }
  }

  void _confirmDelete(Brand brand) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer la marque'),
        content: Text('Voulez-vous supprimer "${brand.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _brands.removeWhere((b) => b.id == brand.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.arrow_back, size: 18, color: AppColors.brandDeep),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: Text('Gérer les marques',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brandDeep)),
                    ),
                  ),
                ],
              ),
            ),

            // Search & Add (use shared AppSearchbar for consistent style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchbar(
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openAddPage(),
                    icon: SvgPicture.asset('assets/icons/plus.svg', width: 14, height: 14, color: Colors.white),
                    label: const Text('+ Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // Table
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Container(
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
                    children: [
                      // Table Header (match products table header look)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _allSelected,
                                onChanged: _toggleSelectAll,
                                shape: const CircleBorder(),
                                activeColor: AppColors.brandDeep,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Expanded(child: Text('Marque', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                            const SizedBox(width: 6),
                            const SizedBox(width: 50, child: Center(child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700)))),
                          ],
                        ),
                      ),

                      // Brand List (use dividers between rows like products table)
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredBrands.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          ),
                          itemBuilder: (context, index) {
                            final brand = _filteredBrands[index];
                            final isSelected = _selected[brand.id] ?? false;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (v) => setState(() => _selected[brand.id] = v ?? false),
                                      shape: const CircleBorder(),
                                      activeColor: AppColors.brandDeep,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(brand.name)),
                                  SizedBox(
                                    width: 50,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () => _openAddPage(edit: brand),
                                          child: SvgPicture.asset('assets/icons/small_edit.svg', width: 16, height: 16, color: AppColors.brandDeep),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => _confirmDelete(brand),
                                          child: SvgPicture.asset('assets/icons/delete.svg', width: 16, height: 16, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
