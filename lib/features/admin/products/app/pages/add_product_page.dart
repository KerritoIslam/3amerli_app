import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../bloc/admin_products_bloc.dart';
import '../bloc/admin_products_event.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:amerli_app/core/config/injection.dart' as di;
import 'package:amerli_app/features/admin/categories/domain/repositories/admin_categories_repository.dart';
import 'package:amerli_app/features/admin/categories/domain/entities/category.dart';
import 'package:amerli_app/features/admin/brands/domain/repositories/admin_brands_repository.dart';
import 'package:amerli_app/features/admin/brands/domain/entities/brand.dart';
import '../../domain/repositories/admin_products_repository.dart';
// import 'package:amerli_app/utils/constants/app_colors.dart';

class AddProductPage extends StatefulWidget {
  final String? productId; // null for add, non-null for edit

  const AddProductPage({super.key, this.productId});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  int _currentStep = 0;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  // keys for individual form fields so we can read/show their errorText
  final GlobalKey<FormFieldState<String>> _nameFieldKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _quantityFieldKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _priceFieldKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _availableQuantityFieldKey = GlobalKey<FormFieldState<String>>();
  // key to measure the form content height so the stepper can match it
  final GlobalKey _formContentKey = GlobalKey();
  double _formContentHeight = 0.0;
  // keys to measure the step labels inside the form so we can align circles
  final GlobalKey _step1LabelKey = GlobalKey();
  final GlobalKey _step2LabelKey = GlobalKey();
  double _labelCenterDistance = 0.0;

  // Step 1 fields
  final TextEditingController _nameController = TextEditingController();
  String? _selectedBrandId; // Store brand ID
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedCategoryId; // Store category ID
  List<Brand> _brands = [];
  List<Category> _categories = [];
  bool _isLoadingData = false;
  late final AdminCategoriesRepository _categoriesRepository;
  late final AdminBrandsRepository _brandsRepository;
  late final AdminProductsRepository _productsRepository;
  final List<String> _specifications = [];
  final TextEditingController _specController = TextEditingController();
  DateTime? _expirationDate;
  bool _isLoadingProduct = false;
  Product? _existingProduct;

  // Step 2 fields
  final TextEditingController _priceController = TextEditingController();
  // stock status is derived from available quantity; removed manual status field
  final TextEditingController _availableQuantityController =
      TextEditingController();
  final List<String> _images = [];
  int _mainImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _categoriesRepository = di.sl<AdminCategoriesRepository>();
    _brandsRepository = di.sl<AdminBrandsRepository>();
    _productsRepository = di.sl<AdminProductsRepository>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load categories and brands first
    await _loadCategoriesAndBrands();
    // Then load product data if editing
    if (widget.productId != null) {
      await _loadProductData();
    }
  }

  Future<void> _loadCategoriesAndBrands() async {
    setState(() => _isLoadingData = true);
    try {
      final categories = await _categoriesRepository.getCategories();
      final brands = await _brandsRepository.getAllBrands();
      setState(() {
        _categories = categories;
        _brands = brands;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  Future<void> _loadProductData() async {
    if (widget.productId == null) return;
    
    setState(() => _isLoadingProduct = true);
    try {
      final product = await _productsRepository.getProductById(widget.productId!);
      setState(() {
        _existingProduct = product;
        // Pre-fill form fields
        _nameController.text = product.name;
        // Find brand ID by name
        final brand = _brands.firstWhere(
          (b) => b.name == product.brand,
          orElse: () => Brand(id: '', name: ''),
        );
        if (brand.id.isNotEmpty) _selectedBrandId = brand.id;
        
        _quantityController.text = product.quantityPerLot.toString();
        
        // Find category ID by name
        final category = _categories.firstWhere(
          (c) => c.name == product.category,
          orElse: () => Category(id: '', name: '', description: '', imageUrl: null, productCount: 0, createdAt: DateTime.now(), updatedAt: DateTime.now()),
        );
        if (category.id.isNotEmpty) _selectedCategoryId = category.id;
        
        _specifications.clear();
        _specifications.addAll(product.specifications);
        _expirationDate = product.expirationDate;
        _priceController.text = product.pricePerLot.toString();
        _availableQuantityController.text = product.availableQuantity.toString();
        
        // Add existing product images (URLs) to the images list
        _images.clear();
        _images.addAll(product.images);
        _mainImageIndex = product.mainImageIndex;
        
        _isLoadingProduct = false;
      });
    } catch (e) {
      setState(() => _isLoadingProduct = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement du produit: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _specController.dispose();
    _priceController.dispose();
    _availableQuantityController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    }
  }

  // previous-step helper removed (not used)

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      setState(() {
        _images.addAll(selectedImages.map((xFile) => xFile.path).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (_mainImageIndex == index) {
        _mainImageIndex = 0;
      } else if (_mainImageIndex > index) {
        _mainImageIndex--;
      }
      _images.removeAt(index);
    });
  }

  void _setMainImage(int index) {
    setState(() {
      _mainImageIndex = index;
    });
  }

  void _addSpecification() {
    if (_specController.text.isNotEmpty) {
      setState(() {
        _specifications.add(_specController.text);
        _specController.clear();
      });
    }
  }

  void _removeSpecification(int index) {
    setState(() {
      _specifications.removeAt(index);
    });
  }

  void _saveProduct() {
    if (_formKey2.currentState!.validate()) {
      final bool isEditing = widget.productId != null;
      
      // For new products, validate that category and brand are selected
      if (!isEditing) {
        if (_selectedCategoryId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
          );
          return;
        }
        if (_selectedBrandId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez sélectionner une marque')),
          );
          return;
        }
      }

      // Reorder images so main image is first
      final reorderedImages = <String>[];
      if (_images.isNotEmpty) {
        reorderedImages.add(_images[_mainImageIndex]);
        for (int i = 0; i < _images.length; i++) {
          if (i != _mainImageIndex) {
            reorderedImages.add(_images[i]);
          }
        }
      }

      // Generate ID for new products
      final String productId = widget.productId ??
          'PRD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Get brand and category NAMES from selected IDs
      final String brandName = _brands.firstWhere(
        (b) => b.id == _selectedBrandId,
        orElse: () => Brand(id: '', name: ''),
      ).name;
      final String categoryName = _categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => Category(id: '', name: '', description: '', imageUrl: null, productCount: 0, createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ).name;

      final product = Product(
        id: productId,
        name: _nameController.text,
        category: categoryName, // Use category NAME
        brand: brandName, // Use brand NAME
        quantityPerLot: int.tryParse(_quantityController.text) ?? 0,
        specifications: _specifications,
        expirationDate: _expirationDate,
        pricePerLot: double.tryParse(_priceController.text) ?? 0.0,
        stockStatus: (int.tryParse(_availableQuantityController.text) ?? 0) > 0 ? 'En stock' : 'Rupture',
        availableQuantity: int.tryParse(_availableQuantityController.text) ?? 0,
        images: reorderedImages, // Use reordered images with main image first
        mainImageIndex: 0, // Main image is now always at index 0
      );

      if (widget.productId == null) {
        context.read<AdminProductsBloc>().add(AdminProductsAddEvent(product));
      } else {
        context
            .read<AdminProductsBloc>()
            .add(AdminProductsUpdateEvent(product));
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // allow the scaffold to resize when the keyboard appears so available
      // constraints reflect the reduced viewport and children with Expanded
      // receive finite height constraints
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (full width)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // App-standard back button (SVG) to match product details page
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
                      child: SvgPicture.asset(
                        'assets/icons/back_arrow.svg',
                        width: 16,
                        height: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                        placeholderBuilder: (context) => Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Centered title
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.productId == null ? 'Ajouter' : 'Modifier',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content with side indicator
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // bottom padding so focused fields are visible above the keyboard
                  final bottomInset = MediaQuery.of(context).viewInsets.bottom + 24.0;
                  // Schedule a post-frame measurement of the form content height
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _measureFormHeight();
                  });

                  // Use a vertical scroll view that contains a Row with two children
                  // so both stepper and form are part of the same scrollable area.
                  // Avoid Expanded inside the scroll (no vertical flex) to prevent
                  // unbounded constraints.
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 12.0,
                      right: 16.0,
                      bottom: bottomInset,
                      top: 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vertical Step Indicator on the left — fixed width
                        Container(
                          width: 40,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                          // build a column where the connector height matches the
                          // measured form content height (so it visually aligns)
                          child: _MeasuredStepper(
                            currentStep: _currentStep,
                            totalSteps: 2,
                            connectorHeight: _computedConnectorHeight(),
                          ),
                        ),

                        // small spacing between indicator and form column
                        const SizedBox(width: 6),

                        // Form Content container — give it the remaining width
                        SizedBox(
                          width: constraints.maxWidth - 40 - 6 - 28, // account for paddings
                          child: Container(
                            key: _formContentKey,
                            child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Action Button (full width)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _currentStep == 0 ? _nextStep : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep == 0 ? 'Suivant' : 'Enregistrer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
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

  void _measureFormHeight() {
    try {
      final ctx = _formContentKey.currentContext;
      if (ctx == null) return;
      final renderBox = ctx.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      final h = renderBox.size.height;
      if (h > 0 && (h - _formContentHeight).abs() > 0.5) {
        setState(() {
          _formContentHeight = h;
        });
      }
      // measure label centers distance if available
      final ctx1 = _step1LabelKey.currentContext;
      final ctx2 = _step2LabelKey.currentContext;
      if (ctx1 != null && ctx2 != null) {
        final rb1 = ctx1.findRenderObject() as RenderBox?;
        final rb2 = ctx2.findRenderObject() as RenderBox?;
        if (rb1 != null && rb2 != null) {
          final p1 = rb1.localToGlobal(Offset.zero);
          final p2 = rb2.localToGlobal(Offset.zero);
          final center1 = p1.dy + rb1.size.height / 2;
          final center2 = p2.dy + rb2.size.height / 2;
          final dist = (center2 - center1).abs();
          if (dist > 0 && (dist - _labelCenterDistance).abs() > 0.5) {
            setState(() {
              _labelCenterDistance = dist;
            });
          }
        }
      }
    } catch (_) {
      // ignore measurement errors
    }
  }

  double _computedConnectorHeight() {
    const double circleDiameter = 12.0;
    // Prefer label-measured center distance when available: connector is
    // centerDistance minus one circle diameter (distance between circle edges).
    if (_labelCenterDistance > 0.5) {
      final h = (_labelCenterDistance - circleDiameter).clamp(0.0, double.infinity);
      return h;
    }

    // fallback: use form height based heuristic
    final subtract = circleDiameter + 6.0 + 6.0 + circleDiameter; // circles + spacings
    final h = (_formContentHeight - subtract).clamp(0.0, double.infinity);
    return h;
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step label aligned with the first circle of the stepper
          const SizedBox(height: 24),
          Container(
            key: _step1LabelKey,
            child: Text(
              'etap 1',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.productId != null 
              ? 'Informations générales (optionnel)'
              : 'Informations générales',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (widget.productId != null) ...[
            const SizedBox(height: 4),
            Text(
              'Modifiez uniquement les champs que vous souhaitez mettre à jour',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Product Name
          _buildTextField(
            label: 'Nom du produit',
            required: true,
            controller: _nameController,
            keyboardType: TextInputType.text,
            inputFormatters: null,
            fieldKey: _nameFieldKey,
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          _buildLabel('Catégorie', required: true),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: _isLoadingData ? 'Chargement...' : 'Sélectionner une catégorie',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              validator: (value) {
                // Only validate as required for new products
                final bool isEditing = widget.productId != null;
                if (!isEditing && value == null) {
                  return 'Catégorie requise';
                }
                return null;
              },
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      ))
                  .toList(),
              onChanged: _isLoadingData ? null : (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Brand (selection)
          _buildLabel('Marque', required: true),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedBrandId,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: _isLoadingData ? 'Chargement...' : 'Sélectionner une marque',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              validator: (value) {
                // Only validate as required for new products
                final bool isEditing = widget.productId != null;
                if (!isEditing && value == null) {
                  return 'Marque requise';
                }
                return null;
              },
              items: _brands
                  .map((b) => DropdownMenuItem(
                        value: b.id,
                        child: Text(b.name),
                      ))
                  .toList(),
              onChanged: _isLoadingData ? null : (value) {
                setState(() {
                  _selectedBrandId = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Quantity per lot
          _buildTextField(
            label: 'Quantité par lot',
            required: true,
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            fieldKey: _quantityFieldKey,
          ),
          const SizedBox(height: 16),

          // Specifications
          _buildLabel('Spécifications'),
          const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: TextFormField(
                    controller: _specController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addSpecification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('+ Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Specifications List
          if (_specifications.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specifications.asMap().entries.map((entry) {
                return Chip(
                  label: Text(entry.value),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeSpecification(entry.key),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),

          // Expiration Date
          _buildLabel('Date d\'expiration', hint: 'JJ/MM/YYYY'),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _expirationDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (date != null) {
                setState(() {
                  _expirationDate = date;
                });
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _expirationDate == null
                        ? 'JJ/MM/YYYY'
                        : '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}',
                    style: TextStyle(
                      color: _expirationDate == null
                          ? Colors.grey.shade500
                          : Colors.black,
                    ),
                  ),
                  Icon(Icons.calendar_today, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step label aligned visually with the second circle of the stepper
          const SizedBox(height: 72),
          Container(
            key: _step2LabelKey,
            child: Text(
              'etap 2',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.productId != null
              ? 'Détails du prix (optionnel)'
              : 'Détails du prix',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (widget.productId != null) ...[
            const SizedBox(height: 4),
            Text(
              'Modifiez uniquement les champs que vous souhaitez mettre à jour',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Price per lot
          _buildTextField(
            label: 'Prix par lot',
            required: true,
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: ' DZD',
            fieldKey: _priceFieldKey,
          ),
          const SizedBox(height: 24),

          const Text(
            'Stock et disponibilité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Stock status removed; derived from available quantity

          // Available Quantity
          _buildTextField(
            label: 'Quantité disponible',
            required: true,
            controller: _availableQuantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            fieldKey: _availableQuantityFieldKey,
          ),
          const SizedBox(height: 24),

          // Images Section
          const Text(
            'Images du produit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Image Thumbnails
          if (_images.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final isMain = index == _mainImageIndex;
                  return GestureDetector(
                    onTap: () => _showImagePreview(index),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMain
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                              width: isMain ? 3 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isMain)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Principale',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(index),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 16),

          // Upload Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.upload_file),
              label: const Text('Choisir un fichier'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showImagePreview(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Image
            Expanded(
              child: Center(
                child: Image.file(File(_images[index])),
              ),
            ),

            // Set as Main Button
            if (index != _mainImageIndex)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _setMainImage(index);
                      Navigator.pop(context);
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Définir comme image principale'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool required = false,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? suffix,
    GlobalKey<FormFieldState<String>>? fieldKey,
  }) {
    // If a FormField key was provided, prefer showing its error text in the
    // hint area above the input (so the input box doesn't change size).
    final String? fieldError = fieldKey?.currentState?.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // show hint or error in the label area
        _buildLabel(label, required: required, hint: fieldError ?? hint, hintIsError: fieldError != null),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextFormField(
            key: fieldKey,
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (_) {
              // rebuild parent so the label/hint can update when validation changes
              if (fieldKey != null) setState(() {});
            },
            decoration: InputDecoration(
              // hide the default error text (we render it in the hint area)
              errorStyle: const TextStyle(height: 0, fontSize: 0, color: Colors.transparent),
              suffixText: suffix,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            style: const TextStyle(fontSize: 14),
            validator: required
                ? (value) {
                    // Only validate as required for new products
                    final bool isEditing = widget.productId != null;
                    if (!isEditing && (value == null || value.isEmpty)) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, {bool required = false, String? hint, bool hintIsError = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(
            hint,
            style: hintIsError
                ? const TextStyle(color: Colors.red, fontSize: 12)
                : TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _MeasuredStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double connectorHeight;

  const _MeasuredStepper({required this.currentStep, required this.totalSteps, required this.connectorHeight});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isCompleted = currentStep >= 1;
    final lineColor = isCompleted ? primary : Colors.grey.shade300;

    Widget circle(int index) {
      final isActive = index == currentStep;
      final isDone = index < currentStep;
      final color = isActive || isDone ? primary : Colors.grey.shade300;
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 250),
        tween: Tween<double>(begin: isActive || isDone ? 0.85 : 1.0, end: 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive || isDone ? color : Colors.white,
                border: Border.all(color: color, width: 2),
              ),
            ),
          );
        },
      );
    }

  // If the user is on the second step (currentStep == 1) we set the desired
  // center-to-center distance between the two circles to 50 pixels so the
  // second circle rises. Convert that to the connector height (center
  // distance minus circle diameter). Otherwise use the measured connector
  // height passed in.
  const double desiredCenterDistanceOnStep2 = 50.0;
  final double circleDiameter = 12.0; // must match circle() size
  final double totalConnector = (currentStep == 1)
    ? (desiredCenterDistanceOnStep2 - circleDiameter).clamp(0.0, double.infinity)
    : connectorHeight.clamp(0.0, double.infinity);

  // We'll render the full connector (no artificial spare gaps) so the circles
  // move to satisfy the totalConnector height. AnimatedContainer will smooth
  // the transition when the step changes.
  final double displayedConnector = totalConnector;
  final double spareAbove = 0.0;
  final double spareBelow = 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(child: circle(0)),
        // spacer above the visible connector (animated for smoothness)
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: spareAbove,
        ),
        // visible connector segment — directly adjacent to the circles
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          width: 2,
          height: displayedConnector,
          color: lineColor,
        ),
        // spacer below the visible connector
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: spareBelow,
        ),
        Center(child: circle(1)),
      ],
    );
  }
}

