import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/entities/category.dart';
import '../bloc/admin_categories_bloc.dart';
import '../bloc/admin_categories_event.dart';
import '../../domain/repositories/admin_categories_repository.dart';
import 'package:amerli_app/core/config/injection.dart' as di;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

import 'package:amerli_app/core/utils/top_toast.dart';

class AddCategoryPage extends StatefulWidget {
  final String? categoryId;
  final Category? category;

  const AddCategoryPage({super.key, this.categoryId, this.category});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  List<Category> _mainCategories = [];
  String? _selectedParentId;

  String? _imagePath;
  late final AdminCategoriesRepository _categoriesRepository;
  bool _isLoadingCategory = false;
  Category? _existingCategory;

  @override
  void initState() {
    super.initState();
    _categoriesRepository = di.sl<AdminCategoriesRepository>();
    if (widget.categoryId != null) {
      _loadCategoryData();
    } else {
      _loadMainCategories();
    }
  }

  Future<void> _loadMainCategories() async {
    try {
      final categories = await _categoriesRepository.getCategories();
      setState(() {
        _mainCategories = categories;
      });
    } catch (e) {
      // Handle error silently or show toast
    }
  }

  Future<void> _loadCategoryData() async {
    if (widget.categoryId == null) return;

    setState(() => _isLoadingCategory = true);
    try {
      Category? category = widget.category;

      // If category not passed, try to fetch only if we really need to (but user says 404)
      // We prioritize the passed object.
      if (category == null && widget.categoryId != null) {
        try {
          // Try to get from repository if possible, but handle failure gracefully
          category =
              await _categoriesRepository.getCategory(widget.categoryId!);
        } catch (_) {
          // Ignore error if endpoint doesn't exist
        }
      }

      final mainCategories = await _categoriesRepository.getCategories();

      setState(() {
        _mainCategories = mainCategories;
        if (category != null) {
          _existingCategory = category;
          _nameController.text = category.name;
          _imagePath = category.imageUrl;
          // If we could get parentId from category, we would set it here
          // _selectedParentId = category.parentId;
        }

        _isLoadingCategory = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategory = false);
      if (mounted) {
        TopToast.show(context, '${AppLanguage.loadingError}: $e',
            isError: true);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
        description: '',
        imageUrl: _imagePath,
        productCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentId: _selectedParentId,
      );

      if (widget.categoryId == null) {
        context
            .read<AdminCategoriesBloc>()
            .add(AdminCategoriesAddEvent(category));
      } else {
        context
            .read<AdminCategoriesBloc>()
            .add(AdminCategoriesUpdateEvent(category));
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
              padding: EdgeInsets.all(16.0.w),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(24.r),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/back_arrow.svg',
                        width: 16.w,
                        height: 16.h,
                        matchTextDirection: true,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    widget.categoryId == null
                        ? AppLanguage.add
                        : AppLanguage.edit,
                    style: TextStyle(
                      fontSize: 20.sp,
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
                padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguage.generalInfo,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Category Name
                      AppTextField(
                        controller: _nameController,
                        hintText: AppLanguage.categoryNameHint,
                        labelText: AppLanguage.categoryNameLabel,
                        validator: (value) => value == null || value.isEmpty
                            ? AppLanguage.fieldRequired
                            : null,
                      ),
                      SizedBox(height: 20.h),

                      // Image Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLanguage.image,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          if (_imagePath != null)
                            InkWell(
                              onTap: _pickImage,
                              child: Text(
                                AppLanguage.replace,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Image Preview
                      if (_imagePath != null)
                        Container(
                          width: double.infinity,
                          height: 150.h,
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: _imagePath!.startsWith('http')
                                ? Image.network(
                                    _imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                          child: Icon(Icons.broken_image,
                                              size: 30.sp));
                                    },
                                  )
                                : Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                          child: Icon(Icons.broken_image,
                                              size: 30.sp));
                                    },
                                  ),
                          ),
                        ),

                      // Upload Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload_file),
                          label: Text(AppLanguage.chooseFile),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Parent Category Section
                      Text(
                        AppLanguage.parentCategoryOptional,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedParentId,
                            isExpanded: true,
                            hint: Text(AppLanguage.selectParentCategory),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(AppLanguage.noneMainCategory),
                              ),
                              ..._mainCategories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedParentId = value;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),

            // Save Button
            Padding(
              padding: EdgeInsets.all(16.0.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLanguage.save,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, size: 20.sp),
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
