import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amerli_app/features/auth/domain/entities/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amerli_app/core/config/injection.dart';
import 'package:amerli_app/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_event.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class UserInformationPage extends StatefulWidget {
  final User? user;
  const UserInformationPage({super.key, this.user});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  // Controllers/form were removed: this page currently shows read-only info

  User? _user;
  String? _imageUrl;
  bool _uploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showImagePickerOptions() async {
    // Use a centered dialog instead of a bottom sheet so it isn't covered by nav bars
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLanguage.editProfilePhoto),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(AppLanguage.takePhoto),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLanguage.chooseFromGallery),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(AppLanguage.cancel))],
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading state
      setState(() => _uploadingImage = true);

      // Upload to backend
      final profileDataSource = sl<ProfileRemoteDataSourceImpl>();
      final newImageUrl = await profileDataSource.uploadProfilePicture(image.path);

      // Update local state
      if (mounted) {
        setState(() {
          _imageUrl = newImageUrl;
          _uploadingImage = false;
        });

        // Update ProfileBloc to persist the change globally
        try {
          final profileBloc = sl<ProfileBloc>();
          profileBloc.add(UpdateProfilePictureEvent(imageUrl: newImageUrl));
        } catch (e) {
          // ProfileBloc might not be registered, continue anyway
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLanguage.profilePhotoUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        setState(() => _uploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLanguage.errorUpdatingPhoto}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        User? latestUser = widget.user;
        if (state is ProfileLoaded) {
          latestUser = state.user;
        }

        // Update local user reference
        _user = latestUser;
        
        // Always update imageUrl if we have a newer profilePic from the user
        if (latestUser?.profilePic != null && 
            latestUser!.profilePic!.isNotEmpty && 
            (latestUser.profilePic!.startsWith('http://') || latestUser.profilePic!.startsWith('https://'))) {
          _imageUrl = latestUser.profilePic;
        } else {
          _imageUrl ??= '';
        }
        
        final hasValidImage = _imageUrl != null && _imageUrl!.isNotEmpty;

        // Layout matches requested design: centered, scrollable, with avatar + edit
        return Scaffold(
          backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Directionality(
                textDirection: TextDirection.ltr,
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
                          colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
                          placeholderBuilder: (context) => const Icon(Icons.arrow_back, size: 16),
                        ),
                      ),
                    ),

                    const Spacer(),

                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          AppLanguage.personalInformation,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
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
                              // Avatar with loading overlay
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  hasValidImage
                                      ? CircleAvatar(
                                          radius: 56,
                                          backgroundColor: Colors.grey.shade200,
                                          backgroundImage: NetworkImage(_imageUrl!),
                                          onBackgroundImageError: (exception, stackTrace) {
                                            // Silently handle image loading errors
                                          },
                                        )
                                      : CircleAvatar(
                                          radius: 56,
                                          backgroundColor: Colors.grey.shade200,
                                          child: const Icon(Icons.person, size: 48, color: Colors.grey),
                                        ),
                                  if (_uploadingImage)
                                    Container(
                                      width: 112,
                                      height: 112,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              // Edit button
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: _uploadingImage ? null : _showImagePickerOptions,
                                    child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).extension<BrandColors>()?.brandTeal ?? AppColors.brandTeal,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2)),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: SvgPicture.asset(
                                        'assets/icons/edit.svg',
                                        width: 8,
                                        height: 8,
                                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                        placeholderBuilder: (_) => const Icon(Icons.edit, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Info fields (left-aligned, reduced spacing, underlined labels)
                        _infoField(label: AppLanguage.storeNameLabel, value: _user?.supermarketName ?? '—'),
                        const SizedBox(height: 10),
                        _infoField(label: AppLanguage.representativeNameLabel, value: _user?.name ?? '—'),
                        const SizedBox(height: 10),
                        _infoField(label: AppLanguage.phone, value: _user?.phoneNumber ?? '—'),
                        const SizedBox(height: 10),
                        _infoField(label: AppLanguage.address, value: _user?.address ?? '—'),

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
                              context.push('/profile/edit', extra: _user);
                            },
                            child: Text(AppLanguage.editMyInfo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
      },
    );
  }

  Widget _infoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).extension<BrandColors>()?.brandDeep ?? AppColors.brandDeep, decoration: TextDecoration.underline),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.start),
      ],
    );
  }
}
