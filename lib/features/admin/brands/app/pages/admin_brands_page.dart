import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/widgets/searchbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/core/config/injection.dart' as di;
import 'package:amerli_app/utils/constants/app_language.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/admin_brands_repository.dart';
import 'add_brand_page.dart';
import 'package:amerli_app/core/utils/top_toast.dart';

class AdminBrandsPage extends StatefulWidget {
  const AdminBrandsPage({super.key});

  @override
  State<AdminBrandsPage> createState() => _AdminBrandsPageState();
}

class _AdminBrandsPageState extends State<AdminBrandsPage> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _selected = {};
  late final AdminBrandsRepository _repository;
  List<Brand> _brands = [];
  bool _isLoading = false;

  // Pagination
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadMoreRunning = false;

  bool get _allSelected =>
      _filteredBrands.isNotEmpty &&
      _filteredBrands.every((b) => _selected[b.id] == true);

  void _toggleSelectAll(bool? v) {
    setState(() {
      for (final b in _filteredBrands) {
        _selected[b.id] = v ?? false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _repository = di.sl<AdminBrandsRepository>();
    _loadBrands();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadMoreRunning &&
        _hasMore &&
        _search.isEmpty) {
      _loadMoreBrands();
    }
  }

  Future<void> _loadBrands() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });
    try {
      final brands = await _repository.getAllBrands(page: 1, limit: 20);
      setState(() {
        _brands = brands;
        _isLoading = false;
        if (brands.length < 20) _hasMore = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        TopToast.show(context, AppLanguage.loadingError, isError: true);
      }
    }
  }

  Future<void> _loadMoreBrands() async {
    if (_isLoadMoreRunning) return;
    setState(() => _isLoadMoreRunning = true);
    try {
      final nextPage = _currentPage + 1;
      final newBrands =
          await _repository.getAllBrands(page: nextPage, limit: 20);
      setState(() {
        _brands.addAll(newBrands);
        _currentPage = nextPage;
        _isLoadMoreRunning = false;
        if (newBrands.length < 20) _hasMore = false;
      });
    } catch (e) {
      setState(() => _isLoadMoreRunning = false);
      if (mounted) {
        TopToast.show(context, AppLanguage.loadingError, isError: true);
      }
    }
  }

  String get _search => _searchController.text.trim().toLowerCase();

  List<Brand> get _filteredBrands {
    if (_search.isEmpty) return _brands;
    return _brands
        .where((b) => b.name.toLowerCase().contains(_search))
        .toList();
  }

  Future<void> _openAddPage({Brand? edit}) async {
    final result = await Navigator.of(context).push<Brand?>(
      MaterialPageRoute(builder: (_) => AddBrandPage(edit: edit)),
    );
    if (result != null && mounted) {
      try {
        Brand savedBrand;
        if (edit != null) {
          // update existing
          savedBrand = await _repository.updateBrand(edit.id, result.name);
          setState(() {
            final idx = _brands.indexWhere((b) => b.id == edit.id);
            if (idx != -1) _brands[idx] = savedBrand;
          });
          if (mounted) {
            TopToast.show(context, AppLanguage.brandUpdated, isError: false);
          }
        } else {
          // add new
          savedBrand = await _repository.createBrand(result.name);
          setState(() => _brands.insert(0, savedBrand));
          if (mounted) {
            TopToast.show(context, AppLanguage.brandAdded, isError: false);
          }
        }
      } catch (e) {
        if (mounted) {
          TopToast.show(context, AppLanguage.error, isError: true);
        }
      }
    }
  }

  void _confirmDelete(Brand brand) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(AppLanguage.delete),
        content: Text(AppLanguage.deleteBrandConfirm(brand.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: Text(AppLanguage.cancel)),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(AppLanguage.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      try {
        await _repository.deleteBrand(brand.id);
        setState(() => _brands.removeWhere((b) => b.id == brand.id));
        if (mounted) {
          TopToast.show(context, AppLanguage.brandDeleted, isError: false);
        }
      } catch (e) {
        if (mounted) {
          TopToast.show(context, AppLanguage.deleteError, isError: true);
        }
      }
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
                  Material(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go('/admin');
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/back_arrow.svg',
                          width: 16,
                          height: 16,
                          matchTextDirection: true,
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                          placeholderBuilder: (context) => Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: Text(AppLanguage.manageBrands,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandDeep)),
                    ),
                  ),
                ],
              ),
            ),

            // Search & Add (use shared AppSearchbar for consistent style)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(AppLanguage.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // Table
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadBrands,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
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
                                Expanded(
                                    child: Text(AppLanguage.brand,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11))),
                                SizedBox(width: 6),
                                SizedBox(
                                    width: 50,
                                    child: Center(
                                        child: Text(AppLanguage.actions,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700)))),
                              ],
                            ),
                          ),

                          // Brand List (use dividers between rows like products table)
                          if (_isLoading)
                            const SizedBox(
                                height: 200,
                                child:
                                    Center(child: CircularProgressIndicator()))
                          else if (_filteredBrands.isEmpty)
                            Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(AppLanguage.noBrandsFound)))
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              itemCount: _filteredBrands.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.12),
                              ),
                              itemBuilder: (context, index) {
                                final brand = _filteredBrands[index];
                                final isSelected = _selected[brand.id] ?? false;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: isSelected,
                                          onChanged: (v) => setState(() =>
                                              _selected[brand.id] = v ?? false),
                                          shape: const CircleBorder(),
                                          activeColor: AppColors.brandDeep,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(brand.name)),
                                      SizedBox(
                                        width: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  _openAddPage(edit: brand),
                                              child: SvgPicture.asset(
                                                  'assets/icons/small_edit.svg',
                                                  width: 16,
                                                  height: 16,
                                                  colorFilter: ColorFilter.mode(
                                                      AppColors.brandDeep,
                                                      BlendMode.srcIn)),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () =>
                                                  _confirmDelete(brand),
                                              child: SvgPicture.asset(
                                                  'assets/icons/delete.svg',
                                                  width: 16,
                                                  height: 16,
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                          Colors.red,
                                                          BlendMode.srcIn)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          if (_isLoadMoreRunning)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
                    ),
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
