import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  // TODO: Replace with actual API call when backend is ready
  @override
  Future<DashboardStats> getDashboardStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock data
    final mockData = DashboardStatsModel(
      totalOrders: 156,
      pendingOrders: 23,
      completedOrders: 120,
      totalUsers: 487,
      totalProducts: 1234,
      totalRevenue: 45678.50,
      recentSales: [
        DailySalesModel(
          date: DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
          amount: 1234.50,
          ordersCount: 12,
        ),
        DailySalesModel(
          date: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          amount: 2345.75,
          ordersCount: 18,
        ),
        DailySalesModel(
          date: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          amount: 1876.20,
          ordersCount: 15,
        ),
        DailySalesModel(
          date: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          amount: 3456.90,
          ordersCount: 25,
        ),
        DailySalesModel(
          date: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          amount: 2987.30,
          ordersCount: 21,
        ),
        DailySalesModel(
          date: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          amount: 4123.85,
          ordersCount: 28,
        ),
        DailySalesModel(
          date: DateTime.now().toIso8601String(),
          amount: 1654.00,
          ordersCount: 11,
        ),
      ],
    );

    return mockData.toEntity();
  }
}
