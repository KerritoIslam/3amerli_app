import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../bloc/admin_products_bloc.dart';
import '../bloc/admin_products_event.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';

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

  // Step 1 fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedCategory;
  final List<String> _specifications = [];
  final TextEditingController _specController = TextEditingController();
  DateTime? _expirationDate;

  // Step 2 fields
  final TextEditingController _priceController = TextEditingController();
  String _stockStatus = 'En stock';
  final TextEditingController _availableQuantityController =
      TextEditingController();
  final List<String> _images = [];
  int _mainImageIndex = 0;

  final List<String> _categories = [
    'Boissons',
    'Boulangerie',
    'Produits Laitiers',
    'Épicerie',
    'Fruits & Légumes',
    'Viandes & Poissons',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
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

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep = _currentStep - 1;
      });
    }
  }

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
      // Generate ID for new products
      final String productId = widget.productId ??
          'PRD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final product = Product(
        id: productId,
        name: _nameController.text,
        category: _selectedCategory ?? '',
        brand: _brandController.text,
        quantityPerLot: int.parse(_quantityController.text),
        specifications: _specifications,
        expirationDate: _expirationDate,
        pricePerLot: double.parse(_priceController.text),
        stockStatus: _stockStatus,
        availableQuantity: int.parse(_availableQuantityController.text),
        images: _images,
        mainImageIndex: _mainImageIndex,
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (full width)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                ],
              ),
            ),

            // Content with side indicator
            Expanded(
              child: Row(
                children: [
                  // Vertical Step Indicator on the left
                  Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                    child: _VerticalStepIndicator(
                      currentStep: _currentStep,
                      totalSteps: 2,
                    ),
                  ),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
                    ),
                  ),
                ],
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

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations générales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Product Name
          AppTextField(
            controller: _nameController,
            hintText: 'Ex: Coca-Cola 1.5L',
            labelText: 'Nom du produit *',
            validator: (value) =>
                value == null || value.isEmpty ? 'Ce champ est requis' : null,
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
              value: _selectedCategory,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Sélectionner une catégorie',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              validator: (value) =>
                  value == null ? 'Catégorie requise' : null,
              items: _categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Brand
          AppTextField(
            controller: _brandController,
            hintText: 'Ex: Coca-Cola',
            labelText: 'Marque *',
            validator: (value) =>
                value == null || value.isEmpty ? 'Ce champ est requis' : null,
          ),
          const SizedBox(height: 16),

          // Quantity per lot
          AppTextField(
            controller: _quantityController,
            hintText: 'Ex: 12',
            labelText: 'Quantité par lot *',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) =>
                value == null || value.isEmpty ? 'Ce champ est requis' : null,
          ),
          const SizedBox(height: 16),

          // Specifications
          _buildLabel('Spécifications'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _specController,
                  hintText: 'Ex: 1.5L',
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
          _buildLabel('Date d\'expiration'),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        ? 'Sélectionner une date'
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
          const Text(
            'Détails du prix',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Price per lot
          AppTextField(
            controller: _priceController,
            hintText: 'Ex: 1800.00',
            labelText: 'Prix par lot *',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: ' DZD',
            validator: (value) =>
                value == null || value.isEmpty ? 'Ce champ est requis' : null,
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

          // Stock Status
          _buildLabel('Statut du stock', required: true),
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
              value: _stockStatus,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'En stock', child: Text('En stock')),
                DropdownMenuItem(value: 'Rupture', child: Text('Rupture')),
              ],
              onChanged: (value) {
                setState(() {
                  _stockStatus = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Available Quantity
          AppTextField(
            controller: _availableQuantityController,
            hintText: 'Ex: 150',
            labelText: 'Quantité disponible *',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) =>
                value == null || value.isEmpty ? 'Ce champ est requis' : null,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildLabel(String label, {bool required = false}) {
    return Row(
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
    );
  }
}

class _VerticalStepIndicator extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  const _VerticalStepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  State<_VerticalStepIndicator> createState() => _VerticalStepIndicatorState();
}

class _VerticalStepIndicatorState extends State<_VerticalStepIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: 1.0, // Full height
      end: 200.0, // 200px from first circle
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: const Color(0xFFA3C335), // Primary color
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.currentStep >= 1) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_VerticalStepIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep >= 1 && oldWidget.currentStep < 1) {
      _animationController.forward();
    } else if (widget.currentStep < 1 && oldWidget.currentStep >= 1) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final isCompleted = widget.currentStep >= 1;
        final lineHeight = isCompleted ? _positionAnimation.value : null;
        final lineColor = isCompleted
            ? _colorAnimation.value ?? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300;

        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // First circle (always at top)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildCircle(
                      context,
                      index: 0,
                      currentStep: widget.currentStep,
                    ),
                  ),
                ),

                // Connecting line
                Positioned(
                  left: 0,
                  right: 0,
                  top: 12,
                  child: Center(
                    child: Container(
                      width: 2,
                      height: lineHeight ?? (constraints.maxHeight - 24),
                      color: lineColor,
                    ),
                  ),
                ),

                // Second circle (animated position)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  top: isCompleted ? lineHeight! + 12 : constraints.maxHeight - 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildCircle(
                      context,
                      index: 1,
                      currentStep: widget.currentStep,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCircle(BuildContext context, {required int index, required int currentStep}) {
    final isActive = index == currentStep;
    final isCircleCompleted = index < currentStep;
    final color = isActive || isCircleCompleted
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade300;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(
        begin: isActive || isCircleCompleted ? 0.8 : 1.0,
        end: 1.0,
      ),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive || isCircleCompleted ? color : Colors.white,
              border: Border.all(color: color, width: 2),
            ),
          ),
        );
      },
    );
  }
}
