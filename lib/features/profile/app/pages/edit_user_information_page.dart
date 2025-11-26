import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amerli_app/features/auth/domain/entities/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_event.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_state.dart';
import 'package:amerli_app/core/ui/toast/toast_service.dart';

class EditUserInformationPage extends StatefulWidget {
  final User? user;
  const EditUserInformationPage({super.key, this.user});

  @override
  State<EditUserInformationPage> createState() =>
      _EditUserInformationPageState();
}

class _EditUserInformationPageState extends State<EditUserInformationPage> {
  late TextEditingController _nameController;
  late TextEditingController _supermarketNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _supermarketNameController =
        TextEditingController(text: widget.user?.supermarketName ?? '');
    _phoneController =
        TextEditingController(text: widget.user?.phoneNumber ?? '');
    _addressController =
        TextEditingController(text: widget.user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _supermarketNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            // Assuming the loaded state with the same user ID means update success if we just triggered it.
            // Ideally we should have a specific success state or check timestamps, but this is simple enough.
            // We can also check if the data matches.
            // For now just go back.
            ToastService.instance
                .showToast(context, AppLanguage.save, type: ToastType.success);
            Navigator.of(context).maybePop();
          } else if (state is ProfileError) {
            ToastService.instance
                .showToast(context, state.message, type: ToastType.error);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header with LTR Directionality for back button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/back_arrow.svg',
                            width: 16,
                            height: 16,
                            matchTextDirection: true,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn),
                            placeholderBuilder: (context) =>
                                const Icon(Icons.arrow_back, size: 16),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            AppLanguage.editMyInfo,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, state) {
                              final user = state is ProfileLoaded
                                  ? state.user
                                  : widget.user;
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: (user?.profilePic != null &&
                                              user!.profilePic!.isNotEmpty)
                                          ? Image.network(
                                              user.profilePic!,
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.grey.shade200,
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(
                          label: AppLanguage.representativeNameLabel,
                          controller: _nameController,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: AppLanguage.storeNameLabel,
                          controller: _supermarketNameController,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: AppLanguage.phone,
                          controller: _phoneController,
                          enabled: false, // Phone usually not editable directly
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: AppLanguage.address,
                          controller: _addressController,
                          // Address editing might require a different UI (map or separate fields), keeping as text for now
                          // If user wants to add/edit address, we might need a separate flow or parse this string
                          enabled:
                              false, // Disable for now as address is complex object
                          hint: "Contact support to change address",
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              final name = _nameController.text.trim();
                              final supermarketName =
                                  _supermarketNameController.text.trim();
                              if (name.isEmpty || supermarketName.isEmpty) {
                                ToastService.instance.showToast(
                                    context, "Please fill all fields",
                                    type: ToastType.error);
                                return;
                              }
                              final data = {
                                'name': name,
                                'supermarketName': supermarketName,
                              };
                              context
                                  .read<ProfileBloc>()
                                  .add(UpdateUserInfoEvent(data: data));
                            },
                            child: Text(AppLanguage.save,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.brandDeep,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            filled: !enabled,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
