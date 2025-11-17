import '../../domain/entities/dashboard_stats.dart';
import 'package:amerli_app/utils/image_resolver.dart';

class DashboardStatsModel {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int totalUsers;
  final int totalProducts;
  final double totalRevenue;
  final List<DailySalesModel> recentSales;
  final List<TopProductModel> topProducts;
  final double ordersPercentageChange;
  final double? revenuePercentageChange;
  final int supermarketsActiveToday;
  final double supermarketsPercentageChange;
  final double deliveredOrdersPercentageChange;
  final int deliveredOrdersCount;

  DashboardStatsModel({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalUsers,
    required this.totalProducts,
    required this.totalRevenue,
    required this.recentSales,
    required this.topProducts,
    required this.ordersPercentageChange,
    required this.revenuePercentageChange,
    required this.supermarketsActiveToday,
    required this.supermarketsPercentageChange,
    required this.deliveredOrdersPercentageChange,
    required this.deliveredOrdersCount,
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
      topProducts: (json['topProducts'] as List<dynamic>?)
              ?.map((e) => TopProductModel.fromJson(e))
              .toList() ??
          [],
      ordersPercentageChange: (json['ordersPercentageChange'] ?? json['orders']?['percentageChange'] ?? 0).toDouble(),
      revenuePercentageChange: json['revenuePercentageChange'] ?? json['revenue']?['percentageChange'],
      supermarketsActiveToday: json['supermarketsActiveToday'] ?? json['supermarkets']?['todayActiveSuperMarkets'] ?? 0,
      supermarketsPercentageChange: (json['supermarketsPercentageChange'] ?? json['supermarkets']?['percentageChange'] ?? 0).toDouble(),
      deliveredOrdersPercentageChange: (json['deliveredOrdersPercentageChange'] ?? json['deliveredOrders']?['percentageChange'] ?? 0).toDouble(),
      deliveredOrdersCount: json['deliveredOrdersCount'] ?? json['deliveredOrders']?['count'] ?? 0,
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
      topProducts: topProducts.map((e) => e.toEntity()).toList(),
      ordersPercentageChange: ordersPercentageChange,
      revenuePercentageChange: revenuePercentageChange,
      supermarketsActiveToday: supermarketsActiveToday,
      supermarketsPercentageChange: supermarketsPercentageChange,
      deliveredOrdersPercentageChange: deliveredOrdersPercentageChange,
      deliveredOrdersCount: deliveredOrdersCount,
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

class TopProductModel {
  final String name;
  final int soldCount;
  final String imageUrl;

  TopProductModel({
    required this.name,
    required this.soldCount,
    required this.imageUrl,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['productName'] ?? json['title'] ?? '').toString();
    final sold = json['soldCount'] ?? json['totalQuantity'] ?? json['sold'] ?? 0;
    int soldCount = 0;
    if (sold is int) {
      soldCount = sold;
    } else if (sold is num) soldCount = sold.toInt();
    else if (sold is String) soldCount = int.tryParse(sold) ?? 0;

    final rawImage = (json['image'] ?? json['productImage'] ?? json['picture'] ?? json['mainpicture'] ?? '').toString();
    String imageUrl = rawImage;
    if (imageUrl.isNotEmpty) {
      try {
        // try to resolve using app util if available
        imageUrl = resolveImageUrl(imageUrl);
      } catch (_) {}
    }

    return TopProductModel(name: name, soldCount: soldCount, imageUrl: imageUrl);
  }

  TopProduct toEntity() {
    return TopProduct(name: name, soldCount: soldCount, imageUrl: imageUrl);
  }
}
