import 'package:amerli_app/features/auth/app/bloc/auth_event.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
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
import 'package:amerli_app/features/auth/domain/entities/user.dart';
import 'package:amerli_app/features/profile/app/pages/user_information_page.dart';
import 'package:amerli_app/features/profile/app/pages/support_and_aide_page.dart';
import 'package:amerli_app/features/profile/app/pages/language_page.dart';

/// Admin profile page: same as regular ProfilePage but without 'Favoris'.
class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  @override
  Widget build(BuildContext context) {
    // Provide ProfileBloc locally and dispatch LoadProfileEvent on creation
    return BlocProvider<ProfileBloc>(
      create: (_) => di.sl<ProfileBloc>()..add(LoadProfileEvent()),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Use Builder to get the correct context that has access to ProfileBloc
    return Builder(
      builder: (builderContext) {
        final bloc = BlocProvider.of<ProfileBloc>(builderContext);

        final content = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              Navigator.of(context).maybePop();
            } catch (_) {}
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).iconTheme.color,
      ),
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
                  child: Builder(builder: (context) {
                    // Try to obtain AuthBloc as a fallback source of user info
                    AuthBloc? authBloc;
                    try {
                      authBloc = BlocProvider.of<AuthBloc>(context);
                    } catch (_) {
                      authBloc = null;
                    }

                    Widget userColumn(User user) {
                      final pic = (user.profilePic ?? '').trim();
                      print("[admin_profile] the user pic is : $pic");
                      final placeholder = 'https://picsum.photos/seed/profile/200/200';

                      // Validate the URL before using it to avoid passing invalid URIs to Image.network
                      final bool hasValidNetworkUrl = pic.isNotEmpty && (Uri.tryParse(pic)?.hasScheme ?? false);
                      if (!hasValidNetworkUrl && pic.isNotEmpty) {
                        // Debug log: in dev builds this helps track down where filenames slip through
                        // ignore: avoid_print
                        print('[admin_profile] profilePic is non-empty but not an absolute URL: $pic');
                      }

                      final imageToLoad = hasValidNetworkUrl ? pic : placeholder;
                      print(  '[admin_profile] loading profile image: $imageToLoad');

                      return Column(
                        children: [
                          const SizedBox(height: 15),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: ClipOval(
                              child: Image.network(
                                imageToLoad,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value: progress.expectedTotalBytes != null
                                            ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  // ignore: avoid_print
                                  print('[admin_profile] image load failed for $imageToLoad -> $error');
                                  // Fallback to a placeholder image on error
                                  return Image.network(
                                    placeholder,
                                    fit: BoxFit.cover,
                                  );
                                },
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

                    Widget placeholderColumn() {
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
                    }

                    // ProfileBloc is now guaranteed to be available
                    return StreamBuilder<ProfileState>(
                      stream: bloc.stream,
                      initialData: bloc.state,
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        if (state is ProfileLoading) return const CircularProgressIndicator();
                        if (state is ProfileLoaded) {
                          // ignore: avoid_print
                          print("[admin_profile] ProfileLoaded with pic: ${state.user.profilePic}");
                          return userColumn(state.user);
                        }

                        // Fallback to AuthBloc when profile couldn't be loaded
                        if (authBloc != null) {
                          return StreamBuilder<AuthState>(
                            stream: authBloc.stream,
                            initialData: authBloc.state,
                            builder: (c, s2) {
                              final aState = s2.data;
                              if (aState is Authenticated) {
                                return userColumn(aState.user);
                              }
                              return placeholderColumn();
                            },
                          );
                        }

                        return placeholderColumn();
                      },
                    );
                  }),
                ),

                const SizedBox(height: 20),
                Text(AppLanguage.myAccount, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                CardsList(
                  items: [
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/Informations_personnelles.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn)),
                      title: Text(AppLanguage.personalInformation, style: Theme.of(context).textTheme.titleSmall),
                      onTap: () async {
                        try {
                          User? user;
                          try {
                            final profileBloc = BlocProvider.of<ProfileBloc>(context);
                            final s = profileBloc.state;
                            if (s is ProfileLoaded) user = s.user;
                          } catch (_) {}

                          if (user == null) {
                            try {
                              final authBloc = BlocProvider.of<AuthBloc>(context);
                              final aState = authBloc.state;
                              if (aState is Authenticated) user = aState.user;
                            } catch (_) {}
                          }

                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserInformationPage(user: user)));
                        } catch (_) {}
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(AppLanguage.additional, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                CardsList(
                  items: [
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/support.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn)),
                      title: Text(AppLanguage.supportAndHelp, style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {
                        try {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportAndAidePage()));
                        } catch (_) {}
                      },
                    ),
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/language.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn)),
                      title: Text(AppLanguage.language, style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {
                        try {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LanguagePage()));
                        } catch (_) {}
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                AppButton(
                  onPressed: () async {
                    try {
                      final router = GoRouter.of(context);
                      final authRepo = di.sl<AuthRepositoryImpl>();
                      await authRepo.signOut();
                      if (!mounted) return;
                      final authBloc = di.sl<AuthBloc>();
                      authBloc.add(LogOutEvent());

                      try {
                        authBloc.stream.firstWhere((s) => s is Unauthenticated).timeout(const Duration(seconds: 2)).then((_) {
                          try {
                            router.go('/auth');
                          } catch (_) {}
                        }).catchError((e) {
                          try {
                            router.go('/auth');
                          } catch (_) {}
                        });
                      } catch (_) {
                        try {
                          router.go('/auth');
                        } catch (_) {}
                      }
                    } catch (e) {
                      if (mounted) {
                        ToastService.instance.showToast(context, 'Déconnexion échouée', type: ToastType.error);
                      }
                    }
                  },
                  backgroundColor: AppColors.brandRed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [SvgPicture.asset('assets/icons/logout.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.lightOnPrimary, BlendMode.srcIn)), const SizedBox(width: 18), Text(AppLanguage.logout, style: AppTextStyles.buttonLargeBold)],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

        // ProfileBloc is always available now, wrap with listener
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
      },
    );
  }
}
