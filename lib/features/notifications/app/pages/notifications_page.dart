import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/features/notifications/app/bloc/notifications_bloc.dart';
import 'package:amerli_app/features/notifications/app/bloc/notifications_event.dart';
import 'package:amerli_app/features/notifications/app/bloc/notifications_state.dart';
import 'package:amerli_app/features/notifications/domain/entities/notification.dart' as ent;
import 'package:amerli_app/features/notifications/app/widgets/notification_card.dart';
import 'package:amerli_app/core/config/injection.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsBloc _bloc;

  @override
  void initState() {
    super.initState();
    // Use the app-scoped NotificationsBloc from DI so state can be reused
    _bloc = sl<NotificationsBloc>();
    // Load notifications when page is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.add(NotificationsLoadEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientFromScheme(Theme.of(context).colorScheme),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Header: use Stack so the title is perfectly centered while
                // the back button stays left-aligned inside the padded area.
                SizedBox(
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Left-aligned back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
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
                            child: SvgPicture.asset('assets/icons/back_arrow.svg', width: 16, height: 16, color: Theme.of(context).colorScheme.onPrimary,
                                placeholderBuilder: (context) => Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary)),
                          ),
                        ),
                      ),

                      // Centered title
                      Center(
                        child: Text('Notifications', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Body
                Expanded(
                  child: BlocBuilder<NotificationsBloc, NotificationsState>(
                    bloc: _bloc,
                    builder: (context, state) {
                      if (state is NotificationsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is NotificationsError) {
                        return Center(child: Text('Erreur: ${state.message}'));
                      }

                      if (state is NotificationsLoaded) {
                        final today = <ent.AppNotification>[];
                        final yesterday = <ent.AppNotification>[];
                        final last7 = <ent.AppNotification>[];

                        final now = DateTime.now();
                        for (final n in state.items) {
                          final d = n.createdAt;
                          final diff = now.difference(d).inDays;
                          if (isSameDate(d, now)) {
                            today.add(n);
                          } else if (diff == 1) {
                            yesterday.add(n);
                          } else {
                            last7.add(n);
                          }
                        }

                        // Determine which section is shown first so we can place the
                        // "Marquer tout comme lu" action next to that section header
                        String? firstSection;
                        if (today.isNotEmpty) {
                          firstSection = 'today';
                        } else if (yesterday.isNotEmpty) firstSection = 'yesterday';
                        else if (last7.isNotEmpty) firstSection = 'last7';

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (today.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                sectionHeaderWithAction('Aujourd\'hui', showAction: firstSection == 'today'),
                                ...today.map((n) => _buildDismissibleNotification(n)),
                              ],
                              if (yesterday.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                sectionHeaderWithAction('Hier', showAction: firstSection == 'yesterday'),
                                ...yesterday.map((n) => _buildDismissibleNotification(n)),
                              ],
                              if (last7.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                sectionHeaderWithAction('Les 7 derniers jours', showAction: firstSection == 'last7'),
                                ...last7.map((n) => _buildDismissibleNotification(n)),
                              ],
                              const SizedBox(height: 40),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleNotification(ent.AppNotification notification) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _bloc.add(NotificationsDeleteEvent(notification.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification supprimée'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: NotificationListCard(
        notification: notification,
        onTap: () => onTapNotification(notification),
      ),
    );
  }

  Widget sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  Widget sectionHeaderWithAction(String text, {required bool showAction}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
          if (showAction)
            TextButton(
              onPressed: () => _bloc.add(NotificationsMarkAllReadEvent()),
              child: Text('Marquer tout comme lu', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary , decoration: TextDecoration.underline , decorationColor: Theme.of(context).colorScheme.primary)),
            ),
        ],
      ),
    );
  }

  bool isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  void onTapNotification(ent.AppNotification n) {
    // For now navigate to orders page or show details - we simply mark read and show snackbar
    _bloc.add(NotificationsToggleReadEvent(n));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ouvrir la commande liée à la notification')));
  }
}
