import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int totalUsers;
  final int totalProducts;
  final double totalRevenue;
  final List<DailySalesModel> recentSales;

  DashboardStatsModel({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalUsers,
    required this.totalProducts,
    required this.totalRevenue,
    required this.recentSales,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      recentSales: (json['recentSales'] as List<dynamic>?)
              ?.map((e) => DailySalesModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  DashboardStats toEntity() {
    return DashboardStats(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      completedOrders: completedOrders,
      totalUsers: totalUsers,
      totalProducts: totalProducts,
      totalRevenue: totalRevenue,
      recentSales: recentSales.map((e) => e.toEntity()).toList(),
    );
  }
}

class DailySalesModel {
  final String date;
  final double amount;
  final int ordersCount;

  DailySalesModel({
    required this.date,
    required this.amount,
    required this.ordersCount,
  });

  factory DailySalesModel.fromJson(Map<String, dynamic> json) {
    return DailySalesModel(
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      ordersCount: json['ordersCount'] ?? 0,
    );
  }

  DailySales toEntity() {
    return DailySales(
      date: DateTime.parse(date),
      amount: amount,
      ordersCount: ordersCount,
    );
  }
}
