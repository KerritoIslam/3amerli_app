import '../../domain/entities/category.dart';
import '../../domain/repositories/admin_categories_repository.dart';

class AdminCategoriesRepositoryImpl implements AdminCategoriesRepository {
  // Mock data
  final List<Category> _mockCategories = [
    Category(
      id: 'CAT001',
      name: 'Alimentation générale',
      description: 'Produits alimentaires de base',
      imageUrl: 'assets/images/categories/food.jpg',
      productCount: 245,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Category(
      id: 'CAT002',
      name: 'Pâtisserie',
      description: 'Gâteaux, viennoiseries et produits sucrés',
      imageUrl: 'assets/images/categories/pastry.jpg',
      productCount: 87,
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Category(
      id: 'CAT003',
      name: 'Boissons',
      description: 'Boissons chaudes et froides',
      imageUrl: 'assets/images/categories/drinks.jpg',
      productCount: 156,
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Category(
      id: 'CAT004',
      name: 'Eaux minérales',
      description: 'Eaux minérales et gazeuses',
      imageUrl: 'assets/images/categories/water.jpg',
      productCount: 34,
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Category(
      id: 'CAT005',
      name: 'Articles pour bébés',
      description: 'Produits pour nourrissons et enfants',
      imageUrl: 'assets/images/categories/baby.jpg',
      productCount: 98,
      createdAt: DateTime.now().subtract(const Duration(days: 70)),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'CAT006',
      name: 'Cosmétiques',
      description: 'Produits de beauté et hygiène',
      imageUrl: 'assets/images/categories/cosmetics.jpg',
      productCount: 123,
      createdAt: DateTime.now().subtract(const Duration(days: 65)),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'CAT007',
      name: 'Emballages',
      description: 'Sacs, boîtes et matériaux d\'emballage',
      imageUrl: 'assets/images/categories/packaging.jpg',
      productCount: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<SubCategory> _mockSubCategories = [
    SubCategory(
      id: 'SUB001',
      name: 'Alimentation de base',
      categoryId: 'CAT001',
      categoryName: 'Alimentation générale',
      productCount: 120,
      createdAt: DateTime.now().subtract(const Duration(days: 85)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    SubCategory(
      id: 'SUB002',
      name: 'Épicerie salée',
      categoryId: 'CAT001',
      categoryName: 'Alimentation générale',
      productCount: 85,
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SubCategory(
      id: 'SUB003',
      name: 'Viennoiseries',
      categoryId: 'CAT002',
      categoryName: 'Pâtisserie',
      productCount: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SubCategory(
      id: 'SUB004',
      name: 'Gâteaux',
      categoryId: 'CAT002',
      categoryName: 'Pâtisserie',
      productCount: 42,
      createdAt: DateTime.now().subtract(const Duration(days: 70)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SubCategory(
      id: 'SUB005',
      name: 'Sodas',
      categoryId: 'CAT003',
      categoryName: 'Boissons',
      productCount: 78,
      createdAt: DateTime.now().subtract(const Duration(days: 65)),
      updatedAt: DateTime.now(),
    ),
    SubCategory(
      id: 'SUB006',
      name: 'Jus de fruits',
      categoryId: 'CAT003',
      categoryName: 'Boissons',
      productCount: 56,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    ),
    SubCategory(
      id: 'SUB007',
      name: 'Couches',
      categoryId: 'CAT005',
      categoryName: 'Articles pour bébés',
      productCount: 34,
      createdAt: DateTime.now().subtract(const Duration(days: 55)),
      updatedAt: DateTime.now(),
    ),
    SubCategory(
      id: 'SUB008',
      name: 'Lingettes',
      categoryId: 'CAT005',
      categoryName: 'Articles pour bébés',
      productCount: 28,
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Category>> getCategories({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (query == null || query.isEmpty) {
      return _mockCategories;
    }

    return _mockCategories.where((cat) {
      return cat.name.toLowerCase().contains(query.toLowerCase()) ||
          cat.id.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Future<List<SubCategory>> getSubCategories({String? categoryId}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (categoryId == null || categoryId.isEmpty) {
      return _mockSubCategories;
    }

    return _mockSubCategories
        .where((sub) => sub.categoryId == categoryId)
        .toList();
  }

  @override
  Future<Category> getCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCategories.firstWhere((cat) => cat.id == id);
  }

  @override
  Future<void> addCategory(Category category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockCategories.add(category);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockCategories.indexWhere((cat) => cat.id == category.id);
    if (index != -1) {
      _mockCategories[index] = category;
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockCategories.removeWhere((cat) => cat.id == id);
    _mockSubCategories.removeWhere((sub) => sub.categoryId == id);
  }

  @override
  Future<void> deleteMultipleCategories(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockCategories.removeWhere((cat) => ids.contains(cat.id));
    _mockSubCategories.removeWhere((sub) => ids.contains(sub.categoryId));
  }

  @override
  Future<void> addSubCategory(SubCategory subCategory) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockSubCategories.add(subCategory);
  }

  @override
  Future<void> updateSubCategory(SubCategory subCategory) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockSubCategories.indexWhere((sub) => sub.id == subCategory.id);
    if (index != -1) {
      _mockSubCategories[index] = subCategory;
    }
  }

  @override
  Future<void> deleteSubCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockSubCategories.removeWhere((sub) => sub.id == id);
  }
}
