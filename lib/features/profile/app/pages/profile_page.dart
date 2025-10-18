import 'package:amerli_app/features/auth/app/bloc/auth_event.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_text_styles.dart';
import 'package:amerli_app/widgets/app_button.dart';
import 'package:amerli_app/widgets/cards_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/auth_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/auth_state.dart';
import 'package:amerli_app/features/auth/repository/auth_repository_impl.dart';
import 'package:amerli_app/core/config/injection.dart' as di;
import 'package:go_router/go_router.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_event.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_state.dart';
import 'package:amerli_app/core/ui/toast/toast_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  bool _profileRequested = false;

  @override
  Widget build(BuildContext context) {
    // Check if ProfileBloc is available; if so, request profile once
    ProfileBloc? bloc;
    try {
      bloc = BlocProvider.of<ProfileBloc>(context);
    } catch (_) {
      bloc = null;
    }

    if (bloc != null && !_profileRequested) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bloc!.add(LoadProfileEvent());
      });
      _profileRequested = true;
    }

    // Build the main scaffold content
    final content = Scaffold(
      body: Center(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: bloc != null
                      ? StreamBuilder<ProfileState>(
                          stream: bloc.stream,
                          initialData: bloc.state,
                          builder: (context, snapshot) {
                            final state = snapshot.data;
                            if (state is ProfileLoading) return const CircularProgressIndicator();
                            if (state is ProfileLoaded) {
                              final user = state.user;
                              return Column(
                                children: [
                                  
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: ClipOval(
                                      child: Image.network(
                                        user.profilePic?.trim().isNotEmpty == true ? user.profilePic! : 'https://picsum.photos/seed/profile/200/200',
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                                            alignment: Alignment.center,
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.person_outline,
                                            size: 48,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 8),
                                  Text(user.phoneNumber, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                                ],
                              );
                            }

                            // initial or error state -> show placeholder while bloc exists
                            return Column(
                              children: [
                                
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: ClipOval(
                                    child: Image.network(
                                      'https://picsum.photos/seed/profile/200/200',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text('Nom d\'utilisateur', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text('Numero de téléphone', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                              ],
                            );
                          },
                        )
                      : Column(
                          children: [
                            
                            const SizedBox(height: 15),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: ClipOval(
                                child: Image.network(
                                  'https://picsum.photos/seed/profile/200/200',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('Nom d\'utilisateur', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('Numero de téléphone', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                          ],
                        ),
                ),

                const SizedBox(height: 20),
                Text('Mon Compte', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                CardsList(
                  items: [
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/Informations_personnelles.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                      title: Text('Informations Personnelles', style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {},
                    ),
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/moyens_de_paiement.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                      title: Text('Moyens de Paiement', style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {},
                    ),
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/mes_commandes.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                      title: Text('Mes Commandes', style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Additionnel', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                CardsList(
                  items: [
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/support.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                      title: Text('Support & Aide', style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {},
                    ),
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/language.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                      title: Text('Language', style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                AppButton(
                  onPressed: () async {
                    // Use the service locator to access AuthBloc and repository.
                    // This avoids errors when the widget context doesn't contain a BlocProvider.
                    try {
                      final authRepo = di.sl<AuthRepositoryImpl>();
                      await authRepo.signOut(); // clear tokens and cached user
                      final authBloc = di.sl<AuthBloc>();
                      // Dispatch logout and wait until the bloc reports Unauthenticated
                      // before navigating. This avoids racing with router redirects
                      // or other listeners that may also update navigation.
                      authBloc.add(LogOutEvent());

                      // Wait for the bloc to emit Unauthenticated (timeout after 2s)
                      try {
                        authBloc.stream.firstWhere((s) => s is Unauthenticated).timeout(const Duration(seconds: 2)).then((_) {
                          try {
                            GoRouter.of(context).go('/auth');
                          } catch (_) {}
                        }).catchError((e) {
                          // If waiting failed/timeout, still attempt navigation as a fallback
                          try {
                            GoRouter.of(context).go('/auth');
                          } catch (_) {}
                        });
                      } catch (_) {
                        try {
                          GoRouter.of(context).go('/auth');
                        } catch (_) {}
                      }
                    } catch (e) {
                      print('Logout failed: $e');
                    }
                  },
                  backgroundColor: AppColors.brandRed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [SvgPicture.asset('assets/icons/logout.svg', width: 24, height: 24, color: AppColors.lightOnPrimary), const SizedBox(width: 18), Text('Se déconnecter', style: AppTextStyles.buttonLargeBold)],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    if (bloc != null) {
      return SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ToastService.instance.showToast(context, state.message, type: ToastType.error);
            }
          },
          child: content,
        ),
      );
    }

    return SafeArea(child: content);
  }
}