import 'package:amerli_app/features/catalog/domain/entities/brand.dart';
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
import 'package:amerli_app/widgets/icon_circle.dart';
import 'package:go_router/go_router.dart';
import '../widgets/top_products_chart.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
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
                      _buildTopProductsSection(context),

                      const SizedBox(height: 100), // Bottom nav padding
                    ],
                  ),
                ),
              );
            }

            if (state is DashboardError) {
              return const Center(
                child: Text('Aucune donnée disponible'),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String userName = 'Admin';
        String? profilePic;

        if (authState is Authenticated) {
          userName = authState.user.name;
          profilePic = authState.user.profilePic;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: profilePic != null && profilePic.isNotEmpty
                    ? NetworkImage(profilePic)
                    : null,
                child: profilePic == null || profilePic.isEmpty
                    ? const Icon(Icons.person, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
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
      },
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Bienvenue sur ',
            style: TextStyle(
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
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 156 / 100,
        children: [
          _StatCard(
            title: 'Commandes\ndu jour',
            value: '${state.stats.totalOrders}',
            percentage: '+11.01%',
            isPositive: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
          ),
          _StatCard(
            title: 'Chiffre\nd\'affaires',
            value: '${state.stats.totalRevenue.toStringAsFixed(0)},00',
            subValue: 'DZD',
            percentage: null,
            isPositive: null,
            backgroundColor: Theme.of(context).extension<BrandColors>()?.brandDeep ?? Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
          ),
          _StatCard(
            title: 'Supérettes\nactives',
            value: '${state.stats.totalUsers}',
            percentage: '+6.74%',
            isPositive: true,
           backgroundColor: Theme.of(context).extension<BrandColors>()?.brandDeep ?? Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
          ),
          _StatCard(
            title: 'Livraisons\nen cours',
            value: '${state.stats.pendingOrders}',
            percentage: '+3.06%',
            isPositive: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(DashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performances',
            style: TextStyle(
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
                  'Évolution des ventes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chiffre d\'affaires et nombre de commandes comparés sur les 6 derniers mois',
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
            children: const [
              Text('Jan', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Fév', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Mar', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Avr', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('May', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Jun', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopProductsSection(BuildContext context) {
    return TopProductsChart();
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
    final maxAmount = sales.map((s) => s.amount).reduce((a, b) => a > b ? a : b);
    final chartHeight = size.height - 30; // Leave space for labels
    final chartWidth = size.width;
    final spacing = chartWidth / (sales.length - 1);

    // Create path for line
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < sales.length; i++) {
      final x = i * spacing;
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

    // Draw line
    canvas.drawPath(path, paint);

    // Draw dots
    for (final point in points) {
      canvas.drawCircle(point, 6, dotBorderPaint);
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
