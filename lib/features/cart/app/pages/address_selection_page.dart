import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:amerli_app/widgets/app_button.dart';
import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:amerli_app/features/auth/domain/repositories/profile_repository.dart';
import 'package:amerli_app/core/config/injection.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:amerli_app/core/utils/top_toast.dart';

class AddressSelectionPage extends StatefulWidget {
  final Map<String, dynamic>? currentAddress;

  const AddressSelectionPage({super.key, this.currentAddress});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _quarterController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isFetchingLocation = false;
  bool _showForm = false;
  bool _isLoadingAddresses = true;
  List<Map<String, dynamic>> _addresses = [];
  int? _selectedAddressId;
  final ProfileRepository _profileRepository = sl<ProfileRepository>();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    // Pre-fill if editing existing address
    if (widget.currentAddress != null) {
      _streetController.text = widget.currentAddress!['street'] ?? '';
      _quarterController.text = widget.currentAddress!['district'] ?? '';
      _cityController.text = widget.currentAddress!['city'] ?? '';
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _profileRepository.getAddresses();
      setState(() {
        _addresses = addresses;
        _isLoadingAddresses = false;
      });
    } catch (e) {
      debugPrint('Failed to load addresses: $e');
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _quarterController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _isFetchingLocation = true);

      LocationPermission permission;
      try {
        permission = await Geolocator.checkPermission();
      } on NoSuchMethodError {
        setState(() => _isFetchingLocation = false);
        if (mounted) {
          if (mounted) {
            TopToast.show(context, AppLanguage.locationPluginUnavailable,
                isError: true);
          }
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() => _isFetchingLocation = false);
        if (mounted) {
          if (mounted) {
            TopToast.show(context, AppLanguage.locationPermissionDenied,
                isError: true);
          }
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isFetchingLocation = false);
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(AppLanguage.permissionRequired),
              content: Text(AppLanguage.locationPermissionPermanentlyDenied),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLanguage.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Geolocator.openAppSettings();
                    Navigator.of(ctx).pop();
                  },
                  child: Text(AppLanguage.openSettings),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Permission granted
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final lat = pos.latitude;
      final lon = pos.longitude;

      // Reverse geocode
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final streetParts = <String>[];
        if (p.street != null && p.street!.trim().isNotEmpty) {
          streetParts.add(p.street!.trim());
        }
        if (p.subLocality != null && p.subLocality!.trim().isNotEmpty) {
          streetParts.add(p.subLocality!.trim());
        }

        setState(() {
          _streetController.text = streetParts.join(', ');
          _quarterController.text =
              p.subAdministrativeArea ?? p.subLocality ?? '';
          _cityController.text = p.locality ?? p.administrativeArea ?? '';
        });
      }
    } catch (e) {
      debugPrint('Location fetch error: $e');
      if (mounted) {
        if (mounted) {
          TopToast.show(context, AppLanguage.unableToGetLocation,
              isError: true);
        }
      }
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  void _onValidate() async {
    // If an existing address is selected, return it with the ID
    if (_selectedAddressId != null) {
      Navigator.of(context).pop({'id': _selectedAddressId});
      return;
    }

    // Otherwise, validate the form for a new address
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    // Create the new address
    final addressData = {
      'street': _streetController.text.trim(),
      'district': _quarterController.text.trim(),
      'city': _cityController.text.trim(),
    };

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Create address via API
      final newAddress = await _profileRepository.createAddress(addressData);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Return the new address with its ID
      if (mounted) {
        Navigator.of(context).pop({'id': newAddress['id']});
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      debugPrint('Failed to create address: $e');
      if (mounted) {
        if (mounted) {
          TopToast.show(context, AppLanguage.addressCreationFailed,
              isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/back_arrow.svg',
              width: 14,
              height: 14,
              color: Theme.of(context).colorScheme.onPrimary,
              placeholderBuilder: (context) => Icon(
                Icons.arrow_back,
                size: 14,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        title: Text(
          AppLanguage.deliveryAddress,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingAddresses
            ? Center(child: CircularProgressIndicator())
            : (_showForm || _addresses.isEmpty)
                ? _buildAddressForm()
                : _buildAddressList(),
      ),
    );
  }

  Widget _buildAddressList() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLanguage.myAddresses,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLanguage.selectDeliveryAddress,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _addresses.length + 1, // +1 for "Add new" button
              itemBuilder: (context, index) {
                if (index == _addresses.length) {
                  // "Add new address" button
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _showForm = true;
                        _selectedAddressId = null;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            AppLanguage.addNewAddress,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final address = _addresses[index];
                final isSelected = _selectedAddressId == address['id'];

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAddressId = address['id'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address['street'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${address['district'] ?? ''}, ${address['city'] ?? ''}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
            child: AppButton(
              onPressed: _selectedAddressId != null ? _onValidate : null,
              text: AppLanguage.validateAddress,
              width: double.infinity,
              height: 50,
            ),
          ),
          SizedBox(height: kBottomNavigationBarHeight + 16),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back to list button
                      if (_addresses.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showForm = false;
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: Text(AppLanguage.backToAddresses),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        AppLanguage.defineYourLocation,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLanguage.enterAddressHint,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      Text(AppLanguage.streetAndNumber,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _streetController,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return AppLanguage.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Text(AppLanguage.districtOrCommune,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      AppTextField(controller: _quarterController),
                      const SizedBox(height: 16),

                      Text(AppLanguage.cityLabel,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      AppTextField(controller: _cityController),
                      const SizedBox(height: 12),

                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AppButton(
                          onPressed: _onValidate,
                          text: AppLanguage.validateAddress,
                          width: double.infinity,
                          height: 50,
                        ),
                      ),

                      Center(
                        child: _isFetchingLocation
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.0),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(AppLanguage.gettingLocation),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: _useCurrentLocation,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    AppLanguage.useCurrentLocation,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ),
                              ),
                      ),
                      // Extra space to clear the bottom nav bar (which is visible from parent route)
                      SizedBox(height: kBottomNavigationBarHeight + 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
