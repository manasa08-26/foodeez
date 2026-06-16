class SettlementSummary {
  final double grossRevenue;
  final double platformFee;
  final double netPayout;
  final int totalOrders;
  final int pendingOrders;

  SettlementSummary({
    required this.grossRevenue,
    required this.platformFee,
    required this.netPayout,
    required this.totalOrders,
    required this.pendingOrders,
  });

  // Legacy fromJson kept for any server that returns the old shape
  factory SettlementSummary.fromJson(Map<String, dynamic> json) =>
      SettlementSummary(
        grossRevenue: _toDouble(json['grossRevenue'] ?? json['totalRevenue']),
        platformFee: _toDouble(json['platformFee'] ?? json['platformCommission']),
        netPayout: _toDouble(json['netPayout']),
        totalOrders: _toInt(json['totalOrders']),
        pendingOrders: _toInt(json['pendingOrders']),
      );
}

class SettlementOrder {
  final String id;
  final String orderNumber;
  final double total;
  final double platformFee;
  final double netAmount;
  final String status;
  final String? createdAt;
  final String? customerName;

  SettlementOrder({
    required this.id,
    required this.orderNumber,
    required this.total,
    required this.platformFee,
    required this.netAmount,
    required this.status,
    this.createdAt,
    this.customerName,
  });

  factory SettlementOrder.fromJson(Map<String, dynamic> json) {
    final total = _toDouble(json['total'] ?? json['orderTotal'] ?? json['totalAmount']);
    const feeRate = 0.05;
    return SettlementOrder(
      id: json['id']?.toString() ?? json['orderId']?.toString() ?? '',
      orderNumber:
          json['orderNumber']?.toString() ?? json['id']?.toString() ?? '',
      total: total,
      platformFee: total * feeRate,
      netAmount: total * (1 - feeRate),
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? json['placedAt']?.toString(),
      customerName: json['customerName']?.toString() ??
          (json['customer'] is Map ? json['customer']['name'] : null)
              ?.toString(),
    );
  }
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
