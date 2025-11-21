import 'package:amerli_app/features/auth/app/bloc/auth_event.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_text_styles.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

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
import 'package:amerli_app/features/favorits/app/pages/favorits_page.dart';

import 'package:amerli_app/features/profile/app/pages/support_and_aide_page.dart';
import 'package:amerli_app/features/profile/app/pages/language_page.dart';
import 'package:amerli_app/features/profile/app/pages/invoices_page.dart';

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
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
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

                    // Helper to build the user column
                    Widget userColumn(User user) {
                      final pic = (user.profilePic ?? '').trim();
                      final imageUrl = pic.isNotEmpty
                          ? pic
                          : 'https://picsum.photos/seed/profile/200/200';
                      return Column(
                        children: [
                          const SizedBox(height: 15),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: ClipOval(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withOpacity(0.6),
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.6),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 48,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(user.name,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(user.phoneNumber,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                        ],
                      );
                    }

                    // Placeholder UI when no user is available
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
                          Text(AppLanguage.name,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(AppLanguage.phone,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                        ],
                      );
                    }

                    if (bloc != null) {
                      return StreamBuilder<ProfileState>(
                        stream: bloc.stream,
                        initialData: bloc.state,
                        builder: (context, snapshot) {
                          final state = snapshot.data;
                          if (state is ProfileLoading)
                            return const CircularProgressIndicator();
                          if (state is ProfileLoaded) {
                            return userColumn(state.user);
                          }

                          // If profile not loaded yet, try to show AuthBloc's user
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
                    }

                    // No ProfileBloc: try AuthBloc directly
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
                  }),
                ),
                const SizedBox(height: 20),
                Text(AppLanguage.myAccount,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                CardsList(
                  items: [
                    CardsListItem(
                      leading: SvgPicture.asset(
                          'assets/icons/Informations_personnelles.svg',
                          width: 24,
                          height: 24,
                          color: Theme.of(context).iconTheme.color),
                      title: Text(AppLanguage.editMyInfo,
                          style: Theme.of(context).textTheme.titleSmall),
                      onTap: () async {
                        try {
                          User? user;
                          // Try ProfileBloc first
                          try {
                            final profileBloc =
                                BlocProvider.of<ProfileBloc>(context);
                            final s = profileBloc.state;
                            if (s is ProfileLoaded) user = s.user;
                          } catch (_) {}

                          // Fallback to AuthBloc
                          if (user == null) {
                            try {
                              final authBloc =
                                  BlocProvider.of<AuthBloc>(context);
                              final aState = authBloc.state;
                              if (aState is Authenticated) user = aState.user;
                            } catch (_) {}
                          }

                          context.push('/profile/info', extra: user);
                        } catch (_) {}
                      },
                    ),
                    CardsListItem(
                      leading: SvgPicture.asset(
                          'assets/icons/favoris_reversed.svg',
                          width: 24,
                          height: 24,
                          color: Theme.of(context).iconTheme.color),
                      title: Text(AppLanguage.favorites,
                          style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {
                        try {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const FavoritsPage()));
                        } catch (_) {}
                      },
                    ),
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/bills.svg',
                          width: 24,
                          height: 24,
                          color: Theme.of(context).iconTheme.color),
                      title: Text(AppLanguage.invoices,
                          style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {
                        try {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const InvoicesPage()));
                        } catch (_) {}
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(AppLanguage.settings,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                CardsList(
                  items: [
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/support.svg',
                          width: 24,
                          height: 24,
                          color: Theme.of(context).iconTheme.color),
                      title: Text(AppLanguage.supportAndHelp,
                          style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {
                        try {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const SupportAndAidePage()));
                        } catch (_) {}
                      },
                    ),
                    CardsListItem(
                      leading: SvgPicture.asset('assets/icons/language.svg',
                          width: 24,
                          height: 24,
                          color: Theme.of(context).iconTheme.color),
                      title: Text(AppLanguage.language,
                          style: Theme.of(context).textTheme.titleSmall),
                      onTap: () {
                        try {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const LanguagePage()));
                        } catch (_) {}
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                AppButton(
                  onPressed: () async {
                    // Use the service locator to access AuthBloc and repository.
                    // This avoids errors when the widget context doesn't contain a BlocProvider.
                    try {
                      final router = GoRouter.of(context);
                      final authRepo = di.sl<AuthRepositoryImpl>();
                      await authRepo.signOut(); // clear tokens and cached user
                      if (!mounted) return;
                      final authBloc = di.sl<AuthBloc>();
                      // Dispatch logout and wait until the bloc reports Unauthenticated
                      // before navigating. This avoids racing with router redirects
                      // or other listeners that may also update navigation.
                      authBloc.add(LogOutEvent());

                      // Wait for the bloc to emit Unauthenticated (timeout after 2s)
                      try {
                        authBloc.stream
                            .firstWhere((s) => s is Unauthenticated)
                            .timeout(const Duration(seconds: 2))
                            .then((_) {
                          try {
                            router.go('/auth');
                          } catch (_) {}
                        }).catchError((e) {
                          // If waiting failed/timeout, still attempt navigation as a fallback
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
                        ToastService.instance.showToast(
                            context, AppLanguage.error,
                            type: ToastType.error);
                      }
                    }
                  },
                  backgroundColor: AppColors.brandRed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/logout.svg',
                          width: 24,
                          height: 24,
                          color: AppColors.lightOnPrimary),
                      const SizedBox(width: 18),
                      Text(AppLanguage.logout,
                          style: AppTextStyles.buttonLargeBold)
                    ],
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
              ToastService.instance
                  .showToast(context, state.message, type: ToastType.error);
            }
          },
          child: content,
        ),
      );
    }

    return SafeArea(child: content);
  }
}
