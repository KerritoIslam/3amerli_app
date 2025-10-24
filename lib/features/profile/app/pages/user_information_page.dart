import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({Key? key}) : super(key: key);

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _imageUrl = 'https://picsum.photos/seed/profile/300/300';

  Future<void> _showImagePickerOptions() async {
    // Simple bottom sheet stub — integrate image_picker plugin if you want
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Prendre une photo'),
              onTap: () {
                // TODO: open camera and update _imageUrl
                Navigator.of(context).pop();
                // simulate change
                setState(() {
                  _imageUrl = 'https://picsum.photos/seed/profile_camera/300/300';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                // TODO: open gallery and update _imageUrl
                Navigator.of(context).pop();
                setState(() {
                  _imageUrl = 'https://picsum.photos/seed/profile_gallery/300/300';
                });
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: wire to bloc/repo to save user info
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Layout matches requested design: centered, scrollable, with avatar + edit
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Back button matching product details style
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
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
                        placeholderBuilder: (context) => const Icon(Icons.arrow_back, size: 16),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Informations personnelles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      // Align text and fields to the start of the page. Elements that
                      // should remain centered (avatar, etc.) are wrapped individually.
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Avatar with edit icon — keep centered while the rest is start-aligned
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 56,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: _showImagePickerOptions,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2)),
                                      ],
                                    ),
                                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Info fields (left-aligned, reduced spacing, underlined labels)
                        _infoField(label: 'Nom de la supérette', value: 'Superette El Malika'),
                        const SizedBox(height: 10),
                        _infoField(label: 'Nom et prénom du représentant', value: 'Nacer Amira Yassamine'),
                        const SizedBox(height: 10),
                        _infoField(label: 'Numéro de téléphone', value: '0655180239'),
                        const SizedBox(height: 10),
                        _infoField(label: 'Adresse complète', value: '12 Rue des Jasmins, Quartier El Mokrani, Aïn Naadja, Alger, Algérie'),

                        const SizedBox(height: 28),

                        // Primary action
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary, // app primary
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              // Open an edit form — simple placeholder page
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _EditUserInformationPage()));
                            },
                            child: const Text('Modifier mes informations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
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

  Widget _infoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green[700], decoration: TextDecoration.underline),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.start),
      ],
    );
  }

}

// Simple placeholder edit page — replace with your real edit flow or a Bloc-backed form
class _EditUserInformationPage extends StatelessWidget {
  const _EditUserInformationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiaryContainer, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: SvgPicture.asset('assets/icons/back_arrow.svg', width: 16, height: 16, placeholderBuilder: (_) => const Icon(Icons.arrow_back, size: 16)),
          ),
        ),
        title: const Text('Modifier mes informations'),
      ),
      body: const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Formulaire d\'édition (à implémenter)'))),
    );
  }

}
