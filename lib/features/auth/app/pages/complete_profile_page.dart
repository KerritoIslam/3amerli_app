import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/auth/sign_up/sign_up_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/widgets/app_button.dart';
import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:amerli_app/widgets/custom_tab_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:amerli_app/core/ui/toast/toast_service.dart';
import 'package:amerli_app/core/network/api_exception.dart' show ApiException;
import 'package:geocoding/geocoding.dart';
import '../../../../utils/constants/app_dimensions.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

import 'package:amerli_app/core/utils/top_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final PageController _pageController = PageController();
  int _index = 0;

  // Credentials form
  final _credentialsKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _repNameController = TextEditingController();

  // Location form
  final _locationKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _quarterController = TextEditingController();
  final _cityController = TextEditingController();
  // location url is intentionally not sent to backend; we don't store it here
  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _pageController.dispose();
    _storeNameController.dispose();
    _repNameController.dispose();
    _streetController.dispose();
    _quarterController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _goTo(int idx) {
    setState(() => _index = idx);
    _pageController.animateToPage(idx,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onCredentialsValidate() {
    final valid = _credentialsKey.currentState?.validate() ?? false;
    if (!valid) return;
    // move to location step
    _goTo(1);
  }

  Future<void> _onLocationValidate() async {
    final valid = _locationKey.currentState?.validate() ?? false;
    if (!valid) return;

    // build profile payload and call cubit to register
    final profile = {
      'name': _repNameController.text.trim(),
      'supermarketName': _storeNameController.text.trim(),
      'address': {
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'district': _quarterController.text.trim(),
      }
    };

    final cubit = BlocProvider.of<SignUpCubit>(context);
    try {
      await cubit.registerProfile(profile);

      // Navigate to Home via GoRouter to keep a single routing API and
      // avoid creating a second Navigator that could conflict with the
      // app-level GoRouter (which manages '/home'). This also clears
      // previous history similar to pushAndRemoveUntil.
      if (!mounted) return;
      GoRouter.of(context).go('/home');
    } catch (e, st) {
      // Log full error
      print("Registration Error: $e\n$st");

      // Show 'Network error' when error denotes network/backend transport issue
      final msg = (e is ApiException && e.isNetworkError)
          ? AppLanguage.networkError
          : (e is ApiException ? e.message : AppLanguage.registrationFailed);
      if (mounted) {
        ToastService.instance.showToast(context, msg, type: ToastType.error);
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _isFetchingLocation = true);

      // The Geolocator plugin can be null at runtime if native platform
      // code wasn't linked (common after adding a plugin and using hot
      // reload). Calling its static methods then throws NoSuchMethodError.
      // Catch that specific error and show a clear message to the developer
      // / tester to fully rebuild the app.
      LocationPermission permission;
      try {
        permission = await Geolocator.checkPermission();
      } on NoSuchMethodError {
        setState(() => _isFetchingLocation = false);
        TopToast.show(context, AppLanguage.locationPluginUnavailable);
        return;
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() => _isFetchingLocation = false);
        TopToast.show(context, AppLanguage.locationPermissionDenied);
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isFetchingLocation = false);
        // Permission denied forever, prompt user to enable from settings
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLanguage.permissionRequired),
            content: Text(AppLanguage.locationPermissionPermanentlyDenied),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLanguage.cancel)),
              TextButton(
                  onPressed: () {
                    Geolocator.openAppSettings();
                    Navigator.of(ctx).pop();
                  },
                  child: Text(AppLanguage.openSettings)),
            ],
          ),
        );
        return;
      }

      // permission granted
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      final lat = pos.latitude;
      final lon = pos.longitude;

      // reverse geocode
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final streetParts = <String>[];
        if (p.street != null && p.street!.trim().isNotEmpty)
          streetParts.add(p.street!.trim());
        if (p.subLocality != null && p.subLocality!.trim().isNotEmpty)
          streetParts.add(p.subLocality!.trim());

        setState(() {
          _streetController.text = streetParts.join(', ');
          _quarterController.text =
              p.subAdministrativeArea ?? p.subLocality ?? '';
          _cityController.text = p.locality ?? p.administrativeArea ?? '';
          // do not persist or send mapsUrl to backend per requirements
        });
      } else {
        // no placemarks, still set maps url
        setState(() {
          // do not persist or send mapsUrl to backend per requirements
        });
      }
    } catch (e, st) {
      // ignore or show error
      debugPrint('Location fetch error: $e\n$st');
      TopToast.show(context, AppLanguage.unableToGetLocation);
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent the scaffold from resizing and moving the bottom button when
      // the keyboard appears. We keep the layout stable and allow inner
      // scrollables to handle keyboard overlap instead.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            CustomTabBar(
              tabs: const [Text(''), Text('')],
              currentIndex: _index,
              // allow tapping previous tabs to go back, but prevent going forward
              onTap: (i) {
                if (i <= _index) _goTo(i);
              },
              indicatorColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Theme.of(context).hintColor,
              indicatorHeight: AppDimensions.spacingXS.h,
              padding: EdgeInsets.symmetric(vertical: 12.0.h),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // disable swipe
                onPageChanged: (p) => setState(() => _index = p),
                children: [
                  // Credentials
                  Padding(
                    padding: EdgeInsets.all(20.0.r),
                    child: Form(
                      key: _credentialsKey,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.h),
                                  Text(AppLanguage.completeYourProfile,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24.sp)),
                                  SizedBox(height: 12.h),
                                  Text(AppLanguage.completeProfileSubtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 14.sp)),
                                  SizedBox(height: 24.h),
                                  Text(AppLanguage.storeNameLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 12.sp)),
                                  SizedBox(height: 8.h),
                                  AppTextField(
                                      controller: _storeNameController,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return AppLanguage.fieldRequired;
                                        return null;
                                      }),
                                  SizedBox(height: 16.h),
                                  Text(AppLanguage.representativeNameLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 12.sp)),
                                  SizedBox(height: 8.h),
                                  AppTextField(controller: _repNameController),
                                  const Spacer(),
                                  AppButton(
                                      onPressed: _onCredentialsValidate,
                                      text: AppLanguage.validateAndContinue,
                                      width: double.infinity,
                                      height: 50.h),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Location
                  Padding(
                    padding: EdgeInsets.all(20.0.r),
                    child: Form(
                      key: _locationKey,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.h),
                                  Text(AppLanguage.defineYourLocation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24.sp)),
                                  SizedBox(height: 12.h),
                                  Text(AppLanguage.enterAddressHint,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 14.sp)),
                                  SizedBox(height: 24.h),

                                  Text(AppLanguage.streetAndNumber,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 12.sp)),
                                  SizedBox(height: 8.h),
                                  AppTextField(
                                      controller: _streetController,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return AppLanguage.fieldRequired;
                                        return null;
                                      }),
                                  SizedBox(height: 16.h),

                                  Text(AppLanguage.districtOrCommune,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 12.sp)),
                                  SizedBox(height: 8.h),
                                  AppTextField(controller: _quarterController),
                                  SizedBox(height: 16.h),

                                  Text(AppLanguage.cityLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 12.sp)),
                                  SizedBox(height: 8.h),
                                  AppTextField(controller: _cityController),
                                  SizedBox(height: 12.h),
                                  // push the button and the trigger down a bit
                                  const Spacer(),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 12.0.h),
                                    child: AppButton(
                                        onPressed: _onLocationValidate,
                                        text: AppLanguage.validateAddress,
                                        width: double.infinity,
                                        height: 50.h),
                                  ),
                                  // place the location trigger under the button and center it
                                  Center(
                                    child: _isFetchingLocation
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 6.0.h),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                      width: 16.w,
                                                      height: 16.w,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth:
                                                                  2.0.w)),
                                                  SizedBox(width: 12.w),
                                                  Text(
                                                      AppLanguage
                                                          .gettingLocation,
                                                      style: TextStyle(
                                                          fontSize: 14.sp)),
                                                ]),
                                          )
                                        : GestureDetector(
                                            onTap: _useCurrentLocation,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.0.h),
                                              child: Text(
                                                AppLanguage.useCurrentLocation,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontSize: 14.sp,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor:
                                                          Theme.of(context)
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
                                  SizedBox(height: 6.h),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
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
