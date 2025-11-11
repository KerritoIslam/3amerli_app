class DashboardStats {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int totalUsers;
  final int totalProducts;
  final double totalRevenue;
  final List<DailySales> recentSales;
  final List<TopProduct> topProducts;

  // Percentage / change metrics returned by analytics endpoints
  final double ordersPercentageChange;
  final double? revenuePercentageChange;
  final int supermarketsActiveToday;
  final double supermarketsPercentageChange;
  final double deliveredOrdersPercentageChange;
  final int deliveredOrdersCount;

  DashboardStats({
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
}

class DailySales {
  final DateTime date;
  final double amount;
  final int ordersCount;

  DailySales({
    required this.date,
    required this.amount,
    required this.ordersCount,
  });
}

class TopProduct {
  final String name;
  final int soldCount;
  final String imageUrl;

  TopProduct({
    required this.name,
    required this.soldCount,
    required this.imageUrl,
  });
}
