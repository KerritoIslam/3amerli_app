import 'package:flutter/material.dart';
import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/brand.dart';

class AddBrandPage extends StatefulWidget {
  final Brand? edit;
  const AddBrandPage({super.key, this.edit});

  @override
  State<AddBrandPage> createState() => _AddBrandPageState();
}

class _AddBrandPageState extends State<AddBrandPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.edit != null) _nameController.text = widget.edit!.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final id =
        widget.edit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final brand = Brand(id: id, name: _nameController.text.trim());
    Navigator.of(context).pop(brand);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // header
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
                      child: const Icon(Icons.arrow_back, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: Text(
                          widget.edit == null
                              ? 'Ajouter une marque'
                              : 'Modifier la marque',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon moved above the field (instead of inside it)
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/small_edit.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                              AppColors.brandDeep, BlendMode.srcIn)),
                      const SizedBox(width: 8),
                      const Text('Nom de la marque *',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: AppTextField(
                      controller: _nameController,
                      hintText: 'Entrez le nom',
                      // label is shown above manually, keep the field compact
                      labelText: null,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Le nom est requis' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Only a single Save button (no Cancel), styled like other pages
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
