class DashboardMetrics {
  final double todayRevenue;
  final int todayOrders;
  final double weekRevenue;
  final int weekOrders;
  final double avgOrderValue;
  final int pendingOrders;
  final int activeOrders;
  final double ratingAverage;
  final List<RevenuePoint> revenueChart;

  DashboardMetrics({
    required this.todayRevenue,
    required this.todayOrders,
    required this.weekRevenue,
    required this.weekOrders,
    required this.avgOrderValue,
    required this.pendingOrders,
    required this.activeOrders,
    required this.ratingAverage,
    required this.revenueChart,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    // Handle both admin and restaurant-specific dashboard shapes
    final restaurant = json['restaurant'] ?? json;
    return DashboardMetrics(
      todayRevenue: _toDouble(restaurant['todayRevenue']),
      todayOrders: _toInt(restaurant['todayOrders']),
      weekRevenue: _toDouble(restaurant['weekRevenue']),
      weekOrders: _toInt(restaurant['weekOrders']),
      avgOrderValue: _toDouble(restaurant['avgOrderValue']),
      pendingOrders: _toInt(restaurant['pendingOrders']),
      activeOrders: _toInt(restaurant['activeOrders']),
      ratingAverage: _toDouble(restaurant['ratingAverage']),
      revenueChart: (restaurant['revenueChart'] as List?)
              ?.whereType<Map>()
              .map((e) => RevenuePoint.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}

class RevenuePoint {
  final String label;
  final double revenue;
  final int orders;

  RevenuePoint({
    required this.label,
    required this.revenue,
    required this.orders,
  });

  factory RevenuePoint.fromJson(Map<String, dynamic> json) => RevenuePoint(
        label: (json['label'] ?? json['date'])?.toString() ?? '',
        revenue: _toDouble(json['revenue']),
        orders: _toInt(json['orders']),
      );
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
