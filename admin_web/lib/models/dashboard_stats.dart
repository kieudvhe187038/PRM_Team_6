import 'order.dart';
import 'product.dart';

/// Doanh thu của 1 ngày (dùng cho biểu đồ 7 ngày gần nhất).
class DailyRevenue {
  final DateTime date;
  final double revenue;

  const DailyRevenue({required this.date, required this.revenue});

  factory DailyRevenue.fromJson(Map<String, dynamic> json) => DailyRevenue(
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
  );
}

/// Số liệu tổng quan cho Dashboard quản lý.
class DashboardStats {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final List<Order> recentOrders;
  final List<Product> topProducts;
  final List<DailyRevenue> revenueLast7Days;
  final Map<String, int> ordersByStatus;

  const DashboardStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.recentOrders,
    required this.topProducts,
    required this.revenueLast7Days,
    required this.ordersByStatus,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
    totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
    totalOrders: json['totalOrders'] ?? 0,
    totalProducts: json['totalProducts'] ?? 0,
    totalCustomers: json['totalCustomers'] ?? 0,
    recentOrders: (json['recentOrders'] as List? ?? [])
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList(),
    topProducts: (json['topProducts'] as List? ?? [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList(),
    revenueLast7Days: (json['revenueLast7Days'] as List? ?? [])
        .map((e) => DailyRevenue.fromJson(e as Map<String, dynamic>))
        .toList(),
    ordersByStatus: (json['ordersByStatus'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    ),
  );
}
