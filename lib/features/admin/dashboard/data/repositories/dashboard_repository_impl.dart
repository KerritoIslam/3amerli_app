import 'package:amerli_app/core/dio/api_service.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_stats_model.dart';

/// Dashboard repository implementation that fetches analytics data from the backend.
///
/// The backend exposes multiple analytics endpoints. This implementation queries
/// the daily-sales endpoint for recent sales and tries to fill missing fields
/// from other analytics endpoints when available. Parsing is defensive so the
/// UI won't crash when the backend shape changes slightly.
class DashboardRepositoryImpl implements DashboardRepository {
  final ApiService apiService;

  DashboardRepositoryImpl({required this.apiService});

  @override
  Future<DashboardStats> getDashboardStats() async {
    // Defensive default values
    int totalOrders = 0;
    int pendingOrders = 0;
    int completedOrders = 0;
    int totalUsers = 0;
    int totalProducts = 0;
    double totalRevenue = 0.0;
    final recentSales = <DailySalesModel>[];
  final topProducts = <TopProductModel>[];
    double ordersPercentageChange = 0.0;
    double? revenuePercentageChange;
    int supermarketsActiveToday = 0;
    double supermarketsPercentageChange = 0.0;
    double deliveredOrdersPercentageChange = 0.0;
  int deliveredOrdersCount = 0;

    try {
      // 1) Try recent/daily sales (expected shape: { data: [ {date, amount, ordersCount}, ... ] })
      final dailyResp = await apiService.get('/analytics/test/daily-stats', queryParameters: {'limit': 7});
      final body = dailyResp.data;
      if (body != null) {
        // If the endpoint returns a structured summary (orders/revenue/supermarkets), extract direct fields
        if (body is Map && (body.containsKey('orders') || body.containsKey('revenue') || body.containsKey('supermarkets') || body.containsKey('deliveredOrders'))) {
          try {
            final orders = body['orders'];
            if (orders is Map) {
              final rawCount = orders['count'] ?? orders['ordersCount'] ?? orders['value'];
              if (rawCount is num) totalOrders = rawCount.toInt();
              else if (rawCount is String) totalOrders = int.tryParse(rawCount) ?? totalOrders;

              final rawPct = orders['percentageChange'] ?? orders['percentChange'] ?? orders['change'];
              if (rawPct is num) ordersPercentageChange = rawPct.toDouble();
              else if (rawPct is String) ordersPercentageChange = double.tryParse(rawPct) ?? ordersPercentageChange;
            }

            final revenue = body['revenue'];
            if (revenue is Map) {
              final rawTurn = revenue['turnover'] ?? revenue['total'] ?? revenue['value'];
              if (rawTurn is num) totalRevenue = rawTurn.toDouble();
              else if (rawTurn is String) totalRevenue = double.tryParse(rawTurn.replaceAll(',', '')) ?? totalRevenue;

              final rawRevPct = revenue['percentageChange'] ?? revenue['percentChange'];
              if (rawRevPct is num) revenuePercentageChange = rawRevPct.toDouble();
              else if (rawRevPct is String) revenuePercentageChange = double.tryParse(rawRevPct);
            }

            final supermarkets = body['supermarkets'];
            if (supermarkets is Map) {
              final rawActive = supermarkets['todayActiveSuperMarkets'] ?? supermarkets['active'] ?? supermarkets['count'];
              if (rawActive is num) supermarketsActiveToday = rawActive.toInt();
              else if (rawActive is String) supermarketsActiveToday = int.tryParse(rawActive) ?? supermarketsActiveToday;

              final rawSuperPct = supermarkets['percentageChange'] ?? supermarkets['percentChange'];
              if (rawSuperPct is num) supermarketsPercentageChange = rawSuperPct.toDouble();
              else if (rawSuperPct is String) supermarketsPercentageChange = double.tryParse(rawSuperPct) ?? supermarketsPercentageChange;
            }

            final delivered = body['deliveredOrders'];
            if (delivered is Map) {
              final rawDelPct = delivered['percentageChange'] ?? delivered['percentChange'];
              if (rawDelPct is num) deliveredOrdersPercentageChange = rawDelPct.toDouble();
              else if (rawDelPct is String) deliveredOrdersPercentageChange = double.tryParse(rawDelPct) ?? deliveredOrdersPercentageChange;
              final rawDelCount = delivered['count'] ?? delivered['value'];
              if (rawDelCount is num) deliveredOrdersCount = rawDelCount.toInt();
              else if (rawDelCount is String) deliveredOrdersCount = int.tryParse(rawDelCount) ?? deliveredOrdersCount;
            }
          } catch (_) {}
        }

        List<dynamic>? list;
        if (body is List) {
          list = body;
        } else if (body is Map) {
          list = (body['data'] as List?) ?? (body['result'] as List?) ?? (body['items'] as List?);
        }

        if (list != null) {
          for (final e in list) {
            try {
              final m = e is Map ? Map<String, dynamic>.from(e) : {};
              final date = (m['date'] ?? m['label'] ?? m['day'] ?? '').toString();
              final amount = (() {
                final a = m['amount'] ?? m['turnover'] ?? m['value'] ?? 0;
                if (a is num) return a.toDouble();
                if (a is String) return double.tryParse(a.replaceAll(',', '')) ?? 0.0;
                return 0.0;
              })();
              final ordersCount = (() {
                final o = m['ordersCount'] ?? m['orders'] ?? m['count'] ?? 0;
                if (o is int) return o;
                if (o is num) return o.toInt();
                if (o is String) return int.tryParse(o) ?? 0;
                return 0;
              })();

              recentSales.add(DailySalesModel(date: date, amount: amount, ordersCount: ordersCount));
            } catch (_) {
              // skip malformed entry
            }
          }
        }
      }
    } catch (e) {
      // ignore — we'll fallback to defaults or other endpoints
    }

    try {
      // 4) Try top products
      final topResp = await apiService.get('/analytics/test/top-products');
      final tb = topResp.data;
      if (tb != null) {
        List<dynamic>? list;
        if (tb is List) list = tb;
        else if (tb is Map) list = (tb['data'] as List?) ?? (tb['result'] as List?) ?? (tb['items'] as List?) ?? (tb['topProducts'] as List?);

        if (list != null) {
          for (final e in list) {
            try {
              if (e is Map) {
                final m = Map<String, dynamic>.from(e);
                topProducts.add(TopProductModel.fromJson(m));
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    try {
      // 2) Try turnover/summary endpoint for totals or monthly turnover list
      final tResp = await apiService.get('/analytics/test/turnover');
      final b = tResp.data;

      // If the endpoint returns a monthly turnover list (e.g. [{month: 'Jan', turnover: 3500}, ...])
      if (b is List) {
        try {
          // Build expected last 6 months (excluding current month) in ascending order
          final now = DateTime.now();
          final expectedMonths = <DateTime>[];
          for (int i = 6; i >= 1; i--) {
            expectedMonths.add(DateTime(now.year, now.month - i, 1));
          }

          const monthNames = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];

          // Map response month -> turnover
          final Map<String, double> turnoverMap = {};
          for (final item in b) {
            if (item is Map) {
              final m = Map<String, dynamic>.from(item);
              final rawMonth = (m['month'] ?? m['label'] ?? m['monthName'] ?? '').toString();
              final rawTurn = m['turnover'] ?? m['value'] ?? m['total'] ?? 0;
              double turn = 0;
              if (rawTurn is num) turn = rawTurn.toDouble();
              else if (rawTurn is String) turn = double.tryParse(rawTurn.replaceAll(',', '')) ?? 0.0;

              if (rawMonth.isNotEmpty) {
                // normalize to 3-letter english month (first 3 chars)
                final key = rawMonth.substring(0, rawMonth.length >= 3 ? 3 : rawMonth.length);
                turnoverMap[key] = turn;
              }
            }
          }

          // Build recentSales from expectedMonths using values from turnoverMap (default 0)
          recentSales.clear();
          for (final dt in expectedMonths) {
            final key = monthNames[dt.month - 1].substring(0, 3);
            final amount = turnoverMap[key] ?? 0.0;
            recentSales.add(DailySalesModel(date: dt.toIso8601String(), amount: amount, ordersCount: 0));
          }

          // set a fallback totalRevenue from the turnover list if not present
          if (totalRevenue == 0.0) {
            totalRevenue = recentSales.map((s) => s.amount).fold<double>(0.0, (p, e) => p + e);
          }
        } catch (_) {
          // ignore parsing errors and fall back on other endpoints
        }
      } else if (b is Map) {
        final rawRevenue = b['totalRevenue'] ?? b['turnover'] ?? b['total'];
        if (rawRevenue != null) {
          if (rawRevenue is num) {
            totalRevenue = rawRevenue.toDouble();
          } else if (rawRevenue is String) {
            totalRevenue = double.tryParse(rawRevenue.replaceAll(',', '')) ?? totalRevenue;
          }
        }

        final rawTotalOrders = b['totalOrders'] ?? b['ordersCount'];
        if (rawTotalOrders != null) {
          if (rawTotalOrders is num) totalOrders = rawTotalOrders.toInt();
          else if (rawTotalOrders is String) totalOrders = int.tryParse(rawTotalOrders) ?? totalOrders;
        }

        final rawPending = b['pendingOrders'] ?? b['pending'];
        if (rawPending != null) {
          if (rawPending is num) pendingOrders = rawPending.toInt();
          else if (rawPending is String) pendingOrders = int.tryParse(rawPending) ?? pendingOrders;
        }

        final rawCompleted = b['completedOrders'] ?? b['delivered'];
        if (rawCompleted != null) {
          if (rawCompleted is num) completedOrders = rawCompleted.toInt();
          else if (rawCompleted is String) completedOrders = int.tryParse(rawCompleted) ?? completedOrders;
        }
      }
    } catch (e) {
      // ignore
    }

    try {
      // 3) Try to fetch counts (users/products) from a summary endpoint if available
      final summaryResp = await apiService.get('/analytics/test/daily-stats');
      final sb = summaryResp.data;
      if (sb is Map) {
        totalUsers = (sb['totalUsers'] ?? sb['usersCount'] ?? totalUsers) as int? ?? totalUsers;
        totalProducts = (sb['totalProducts'] ?? sb['productsCount'] ?? totalProducts) as int? ?? totalProducts;
      }
    } catch (_) {}

    // Fallback computations if some values are still zero
    if (totalRevenue == 0.0 && recentSales.isNotEmpty) {
      totalRevenue = recentSales.map((s) => s.amount).reduce((a, b) => a + b);
    }
    if (totalOrders == 0 && recentSales.isNotEmpty) {
      totalOrders = recentSales.map((s) => s.ordersCount).fold<int>(0, (p, e) => p + e);
    }

    final model = DashboardStatsModel(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      completedOrders: completedOrders,
      totalUsers: totalUsers,
      totalProducts: totalProducts,
      totalRevenue: totalRevenue,
      recentSales: recentSales,
      topProducts: topProducts,
      ordersPercentageChange: ordersPercentageChange,
      revenuePercentageChange: revenuePercentageChange,
      supermarketsActiveToday: supermarketsActiveToday,
      supermarketsPercentageChange: supermarketsPercentageChange,
      deliveredOrdersPercentageChange: deliveredOrdersPercentageChange,
      deliveredOrdersCount: deliveredOrdersCount,
    );

    return model.toEntity();
  }
}
