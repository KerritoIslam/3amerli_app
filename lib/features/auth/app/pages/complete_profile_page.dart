import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/auth/sign_up/sign_up_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/widgets/app_button.dart';
import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:amerli_app/widgets/custom_tab_bar.dart';
import '../../../../utils/constants/app_dimensions.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({Key? key}) : super(key: key);

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
    _pageController.animateToPage(idx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onCredentialsValidate() {
    final valid = _credentialsKey.currentState?.validate() ?? false;
    if (!valid) return;
    // move to location step
    _goTo(1);
  }

  void _onLocationValidate() {
    final valid = _locationKey.currentState?.validate() ?? false;
    if (!valid) return;
    // build profile payload and call cubit to register
    final profile = {
      'name': _repNameController.text.trim(),
      'locationUrl':"https://maps.google.com/?q=36.7528,3.0422",
      'supermarketName': _storeNameController.text.trim(),
      'role': 'SUPERMARKET',
      'address': {
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'district': _quarterController.text.trim(),
      }
    };
    
    final cubit = BlocProvider.of<SignUpCubit>(context);
    cubit.registerProfile(profile).then((_) {
      // Navigate to Home via GoRouter to keep a single routing API and
      // avoid creating a second Navigator that could conflict with the
      // app-level GoRouter (which manages '/home'). This also clears
      // previous history similar to pushAndRemoveUntil.
      
      GoRouter.of(context).go('/home');
    }).catchError((e) {
      print("Registration Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Échec de l\'enregistrement')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              indicatorHeight: AppDimensions.spacingXS,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // disable swipe
                onPageChanged: (p) => setState(() => _index = p),
                children: [
                  // Credentials
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _credentialsKey,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text('Complétez votre profil', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Text('Ces informations nous permettent de personnaliser vos offres et de valider votre compte.', style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 24),

                                  Text('Nom de la supérette *', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 8),
                                  AppTextField(controller: _storeNameController, validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Ce champ est requis';
                                    return null;
                                  }),
                                  const SizedBox(height: 16),

                                  Text('Nom et prénom du représentant', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 8),
                                  AppTextField(controller: _repNameController),
                                  const Spacer(),
                                  AppButton(onPressed: _onCredentialsValidate, text: 'Valider et continuer', width: double.infinity, height: 50),
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
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _locationKey,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text('Définissez votre localisation', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Text('Précisez votre adresse pour recevoir vos livraisons.', style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 24),

                                  Text('Rue et numéro *', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 8),
                                  AppTextField(controller: _streetController, validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Ce champ est requis';
                                    return null;
                                  }),
                                  const SizedBox(height: 16),

                                  Text('Quartier / Commune', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 8),
                                  AppTextField(controller: _quarterController),
                                  const SizedBox(height: 16),

                                  Text('Ville', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 8),
                                  AppTextField(controller: _cityController),
                                  const Spacer(),
                                  AppButton(onPressed: _onLocationValidate, text: 'Valider l\'adresse', width: double.infinity, height: 50),
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
