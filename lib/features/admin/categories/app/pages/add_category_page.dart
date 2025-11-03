import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/entities/category.dart';
import '../bloc/admin_categories_bloc.dart';
import '../bloc/admin_categories_event.dart';

class AddCategoryPage extends StatefulWidget {
  final String? categoryId;

  const AddCategoryPage({super.key, this.categoryId});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _subCategoryControllers = [
    TextEditingController(),
  ];
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _subCategoryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSubCategoryField() {
    setState(() {
      _subCategoryControllers.add(TextEditingController());
    });
  }

  void _removeSubCategoryField(int index) {
    setState(() {
      _subCategoryControllers[index].dispose();
      _subCategoryControllers.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final categoryId = widget.categoryId ??
          'CAT${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final category = Category(
        id: categoryId,
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _imagePath,
        productCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.categoryId == null) {
        context.read<AdminCategoriesBloc>().add(AdminCategoriesAddEvent(category));
      } else {
        context.read<AdminCategoriesBloc>().add(AdminCategoriesUpdateEvent(category));
      }

      // Add subcategories
      for (var controller in _subCategoryControllers) {
        if (controller.text.isNotEmpty) {
          final subCategoryId =
              'SUB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
          final subCategory = SubCategory(
            id: subCategoryId,
            name: controller.text,
            categoryId: categoryId,
            categoryName: _nameController.text,
            productCount: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          context.read<AdminCategoriesBloc>().add(
                AdminSubCategoriesAddEvent(subCategory),
              );
        }
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
            // Header
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
                  const SizedBox(width: 16),
                  Text(
                    widget.categoryId == null ? 'Ajouter' : 'Modifier',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
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

                      // Category Name
                      AppTextField(
                        controller: _nameController,
                        hintText: 'Ex: Alimentation générale',
                        labelText: 'Nom de la catégorie *',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ce champ est requis'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      AppTextField(
                        controller: _descriptionController,
                        hintText: 'Entrez une description',
                        labelText: 'Description *',
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ce champ est requis'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Image Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Image',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          if (_imagePath != null)
                            InkWell(
                              onTap: _pickImage,
                              child: Text(
                                'Remplacer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Image Preview
                      if (_imagePath != null)
                        Container(
                          width: double.infinity,
                          height: 150,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Upload Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
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

                      const SizedBox(height: 32),

                      // Subcategories Section
                      const Text(
                        'Sous-catégories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Subcategory Fields
                      ..._subCategoryControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: controller,
                                  hintText: 'Ex: Alimentation de base',
                                  labelText: 'Sous-catégorie ${index + 1}',
                                ),
                              ),
                              if (_subCategoryControllers.length > 1) ...[
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _removeSubCategoryField(index),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),

                      // Add Subcategory Button
                      ElevatedButton(
                        onPressed: _addSubCategoryField,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('+ Ajouter'),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Enregistrer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
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
