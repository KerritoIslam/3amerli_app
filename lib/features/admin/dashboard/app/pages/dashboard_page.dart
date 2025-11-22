import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../domain/entities/dashboard_stats.dart';
import 'package:amerli_app/core/error/error_handler.dart';
import 'package:amerli_app/features/auth/app/bloc/auth_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/auth_state.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_bloc.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_event.dart';
import 'package:amerli_app/features/auth/app/bloc/profile_state.dart';
import 'package:amerli_app/features/profile/app/pages/admin_profile_page.dart';
import 'package:amerli_app/widgets/icon_circle.dart';
import 'package:go_router/go_router.dart';
import '../widgets/top_products_chart.dart';
import 'package:amerli_app/core/config/injection.dart' as di;
import 'package:amerli_app/utils/constants/app_language.dart';

// Small helper to carry display values without importing User entity here
class UserDisplay {
  final String name;
  final String? profilePic;
  UserDisplay({required this.name, this.profilePic});
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadEvent());
    // Request latest profile from server; fallback to cached auth on error/offline
    // NOTE: We no longer dispatch LoadProfileEvent here. The Dashboard's
    // build() wraps the subtree in a local BlocProvider<ProfileBloc>, but
    // that provider is a child of this widget's context, so calling
    // context.read<ProfileBloc>() here cannot find it. The event is instead
    // dispatched when the Bloc is created in the BlocProvider.create callback
    // below.
  }

  @override
  Widget build(BuildContext context) {
    // Ensure a ProfileBloc is available for children (use DI factory). If a
    // parent already provides ProfileBloc, this will shadow it harmlessly.
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) => BlocProvider<ProfileBloc>(
        create: (_) => di.sl<ProfileBloc>()..add(LoadProfileEvent()),
        child: BlocListener<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state is DashboardError) {
              ErrorHandler.showError(context, state.message);
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFFFFEFB),
            body: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DashboardLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DashboardBloc>().add(DashboardLoadEvent());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          _buildProfileHeader(context),

                          // Welcome Banner
                          _buildWelcomeBanner(context),

                          // Stats Grid (2x2)
                          _buildStatsGrid(state),

                          // Performance Section
                          _buildPerformanceSection(state),

                          // Top Products Section
                          _buildTopProductsSection(context, state),

                          const SizedBox(height: 100), // Bottom nav padding
                        ],
                      ),
                    ),
                  );
                }

                if (state is DashboardError) {
                  return Center(
                    child: Text(AppLanguage.noDataAvailable),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    // Try to show the freshest profile via ProfileBloc. If profile load fails or
    // the bloc is not present, fall back to AuthBloc cached user.
    ProfileBloc? profileBloc;
    try {
      profileBloc = BlocProvider.of<ProfileBloc>(context);
    } catch (_) {
      profileBloc = null;
    }

    AuthBloc? authBloc;
    try {
      authBloc = BlocProvider.of<AuthBloc>(context);
    } catch (_) {
      authBloc = null;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // Avatar + navigation to admin profile
          Builder(builder: (ctx) {
            Widget avatar(UserDisplay userDisplay) {
              // Validate the URL before using it to avoid passing invalid URIs to NetworkImage
              final pic = userDisplay.profilePic;
              final bool hasValidNetworkUrl = pic != null &&
                  pic.isNotEmpty &&
                  (Uri.tryParse(pic)?.hasScheme ?? false);

              return GestureDetector(
                onTap: () {
                  try {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const AdminProfilePage()));
                  } catch (_) {}
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  backgroundImage:
                      hasValidNetworkUrl ? NetworkImage(pic) : null,
                  child: !hasValidNetworkUrl
                      ? Icon(Icons.person,
                          size: 24,
                          color: Theme.of(context).colorScheme.onSurface)
                      : null,
                ),
              );
            }

            // Use ProfileBloc stream when available
            if (profileBloc != null) {
              return StreamBuilder<ProfileState>(
                stream: profileBloc.stream,
                initialData: profileBloc.state,
                builder: (c, s) {
                  final st = s.data;
                  if (st is ProfileLoaded) {
                    return avatar(UserDisplay(
                        name: st.user.name, profilePic: st.user.profilePic));
                  }
                  if (st is ProfileLoading)
                    return const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2));
                  // on error/fallback show cached auth if available
                  if (authBloc != null && authBloc.state is Authenticated) {
                    final u = (authBloc.state as Authenticated).user;
                    return avatar(
                        UserDisplay(name: u.name, profilePic: u.profilePic));
                  }
                  return avatar(
                      UserDisplay(name: AppLanguage.admin, profilePic: null));
                },
              );
            }

            // No ProfileBloc: try AuthBloc directly
            if (authBloc != null && authBloc.state is Authenticated) {
              final u = (authBloc.state as Authenticated).user;
              return avatar(
                  UserDisplay(name: u.name, profilePic: u.profilePic));
            }

            return avatar(
                UserDisplay(name: AppLanguage.admin, profilePic: null));
          }),

          const SizedBox(width: 12),
          Expanded(
            child: Builder(builder: (ctx) {
              // Name + role: use ProfileBloc then fallback to AuthBloc
              if (profileBloc != null) {
                return StreamBuilder<ProfileState>(
                  stream: profileBloc.stream,
                  initialData: profileBloc.state,
                  builder: (c, s) {
                    final st = s.data;
                    String name = AppLanguage.admin;
                    if (st is ProfileLoaded) {
                      name = st.user.name;
                    } else if (authBloc != null &&
                        authBloc.state is Authenticated)
                      name = (authBloc.state as Authenticated).user.name;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          AppLanguage.admin,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }

              if (authBloc != null && authBloc.state is Authenticated) {
                final u = (authBloc.state as Authenticated).user;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      AppLanguage.admin,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLanguage.admin,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    AppLanguage.admin,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              );
            }),
          ),

          InkWell(
            onTap: () => context.push('/notifications'),
            borderRadius: BorderRadius.circular(20),
            child: IconCircle(
              asset: 'assets/icons/notifications.svg',
              isSelected: false,
              size: 40,
              keepIconColor: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            AppLanguage.welcomeTo,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // Logo placeholder - replace with actual logo
          Image.asset(
            'assets/logo/full_logo.png',
            height: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardLoaded state) {
    return Padding(
      // Reduce the vertical padding so the performance section sits closer
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        // remove any internal grid padding (was causing extra sliver padding)
        padding: EdgeInsets.zero,
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 156 / 100,
        children: [
          // Orders today (count + percent)
          _StatCard(
            title: AppLanguage.ordersToday,
            value: '${state.stats.totalOrders}',
            percentage: state.stats.ordersPercentageChange != 0
                ? '${state.stats.ordersPercentageChange > 0 ? '+' : ''}${state.stats.ordersPercentageChange.toStringAsFixed(2)}%'
                : null,
            isPositive: state.stats.ordersPercentageChange == 0
                ? null
                : state.stats.ordersPercentageChange > 0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
          ),

          // Turnover
          _StatCard(
            title: AppLanguage.turnover,
            value: '${state.stats.totalRevenue.toStringAsFixed(0)},00',
            subValue: 'DZD',
            percentage: state.stats.revenuePercentageChange != null
                ? '${state.stats.revenuePercentageChange! > 0 ? '+' : ''}${state.stats.revenuePercentageChange!.toStringAsFixed(2)}%'
                : null,
            isPositive: state.stats.revenuePercentageChange == null
                ? null
                : state.stats.revenuePercentageChange! > 0,
            backgroundColor:
                Theme.of(context).extension<BrandColors>()?.brandDeep ??
                    Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
          ),

          // Active supermarkets
          _StatCard(
            title: AppLanguage.activeSupermarkets,
            value: '${state.stats.supermarketsActiveToday}',
            percentage: state.stats.supermarketsPercentageChange != 0
                ? '${state.stats.supermarketsPercentageChange > 0 ? '+' : ''}${state.stats.supermarketsPercentageChange.toStringAsFixed(2)}%'
                : null,
            isPositive: state.stats.supermarketsPercentageChange == 0
                ? null
                : state.stats.supermarketsPercentageChange > 0,
            backgroundColor:
                Theme.of(context).extension<BrandColors>()?.brandDeep ??
                    Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
          ),

          // Deliveries (delivered orders count)
          _StatCard(
            title: AppLanguage.deliveriesInProgress,
            value: '${state.stats.deliveredOrdersCount}',
            percentage: state.stats.deliveredOrdersPercentageChange != 0
                ? '${state.stats.deliveredOrdersPercentageChange > 0 ? '+' : ''}${state.stats.deliveredOrdersPercentageChange.toStringAsFixed(2)}%'
                : null,
            isPositive: state.stats.deliveredOrdersPercentageChange == 0
                ? null
                : state.stats.deliveredOrdersPercentageChange > 0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(DashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLanguage.performance,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(4, 4),
                ),
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(-4, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.salesEvolution,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLanguage.salesEvolutionDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSalesChart(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(DashboardLoaded state) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _SalesChartPainter(state.stats.recentSales),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: state.stats.recentSales.isNotEmpty
                ? state.stats.recentSales
                    .map((d) => Text(
                          _shortMonth(d.date.month),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ))
                    .toList()
                : [
                    Text(AppLanguage.jan,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(AppLanguage.feb,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(AppLanguage.mar,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(AppLanguage.apr,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(AppLanguage.may,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(AppLanguage.jun,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
          ),
        ),
      ),
    );
  }

  // Short French month abbreviations
  String _shortMonth(int month) {
    final months = [
      AppLanguage.jan,
      AppLanguage.feb,
      AppLanguage.mar,
      AppLanguage.apr,
      AppLanguage.may,
      AppLanguage.jun,
      AppLanguage.jul,
      AppLanguage.aug,
      AppLanguage.sep,
      AppLanguage.oct,
      AppLanguage.nov,
      AppLanguage.dec
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  Widget _buildTopProductsSection(BuildContext context, DashboardLoaded state) {
    return TopProductsChart(products: state.stats.topProducts);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final String? percentage;
  final bool? isPositive;
  final Color backgroundColor;
  final Color textColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.subValue,
    this.percentage,
    this.isPositive,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.9),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (percentage != null)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    size: 12,
                    color: textColor,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    subValue!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (percentage != null) ...[
            const SizedBox(height: 2),
            Text(
              percentage!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Custom painter for sales chart
class _SalesChartPainter extends CustomPainter {
  final List<DailySales> sales;

  _SalesChartPainter(this.sales);

  @override
  void paint(Canvas canvas, Size size) {
    if (sales.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFA6CE39)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFA6CE39)
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Find max value for scaling
    double maxAmount =
        sales.map((s) => s.amount).reduce((a, b) => a > b ? a : b).toDouble();
    // avoid divide-by-zero when all amounts are zero
    if (maxAmount == 0) maxAmount = 1;
    final chartHeight = size.height - 30; // Leave space for labels
    final chartWidth = size.width;
    // spacing: if there is only one point, avoid division by zero
    final spacing =
        sales.length > 1 ? chartWidth / (sales.length - 1) : chartWidth;

    // Create path for line
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < sales.length; i++) {
      final x = sales.length > 1 ? i * spacing : chartWidth / 2;
      final y = chartHeight - (sales[i].amount / maxAmount * chartHeight);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Create smooth curve
        final prevPoint = points[i - 1];
        final controlPoint1 = Offset(
          prevPoint.dx + (x - prevPoint.dx) / 2,
          prevPoint.dy,
        );
        final controlPoint2 = Offset(
          prevPoint.dx + (x - prevPoint.dx) / 2,
          y,
        );
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          x,
          y,
        );
      }
    }

    // Draw line if there is more than one point
    if (points.length > 1) {
      canvas.drawPath(path, paint);
    }

    // Draw dots (for single or multiple points)
    for (final point in points) {
      canvas.drawCircle(point, 6, dotBorderPaint);
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
