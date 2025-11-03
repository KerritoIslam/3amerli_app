class DashboardStats {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int totalUsers;
  final int totalProducts;
  final double totalRevenue;
  final List<DailySales> recentSales;

  DashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalUsers,
    required this.totalProducts,
    required this.totalRevenue,
    required this.recentSales,
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
