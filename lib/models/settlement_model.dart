enum SettlementPeriod { today, week, month }

extension SettlementPeriodApi on SettlementPeriod {
  String get apiPath => switch (this) {
        SettlementPeriod.today => 'today',
        SettlementPeriod.week => 'week',
        SettlementPeriod.month => 'month',
      };

  String get label => switch (this) {
        SettlementPeriod.today => 'Today',
        SettlementPeriod.week => 'Week',
        SettlementPeriod.month => 'Month',
      };

  String get netPayoutTitle => switch (this) {
        SettlementPeriod.today => "TODAY'S NET PAYOUT",
        SettlementPeriod.week => "THIS WEEK'S NET PAYOUT",
        SettlementPeriod.month => "THIS MONTH'S NET PAYOUT",
      };

  String get breakdownLabel => switch (this) {
        SettlementPeriod.today => 'Today',
        SettlementPeriod.week => 'This week',
        SettlementPeriod.month => 'This month',
      };
}

class SettlementSummary {
  final String? date;
  final int orderCount;
  final double totalItemValue;
  final double totalCommission;
  final double totalRestaurantShare;
  final double taxesAndAdjustments;
  final String? status;
  final String? nextTransferAt;

  SettlementSummary({
    this.date,
    required this.orderCount,
    required this.totalItemValue,
    required this.totalCommission,
    required this.totalRestaurantShare,
    this.taxesAndAdjustments = 0,
    this.status,
    this.nextTransferAt,
  });

  double get netPayout => totalRestaurantShare;
  double get grossRevenue => totalItemValue;
  double get platformFee => totalCommission;

  double get platformFeeRate =>
      totalItemValue > 0 ? (totalCommission / totalItemValue) * 100 : 0;

  double get avgOrderValue =>
      orderCount > 0 ? totalItemValue / orderCount : 0;

  bool get isSettled =>
      (status ?? '').toUpperCase() == 'SETTLED' || orderCount > 0;

  factory SettlementSummary.fromJson(Map<String, dynamic> json) =>
      SettlementSummary(
        date: json['date']?.toString(),
        orderCount: _toInt(json['orderCount'] ?? json['totalOrders']),
        totalItemValue: _toDouble(
          json['totalItemValue'] ??
              json['grossRevenue'] ??
              json['totalRevenue'],
        ),
        totalCommission: _toDouble(
          json['totalCommission'] ??
              json['platformFee'] ??
              json['platformCommission'],
        ),
        totalRestaurantShare: _toDouble(
          json['totalRestaurantShare'] ??
              json['netPayout'] ??
              json['restaurantShare'],
        ),
        taxesAndAdjustments: _toDouble(
          json['taxesAndAdjustments'] ??
              json['taxes'] ??
              json['adjustments'],
        ),
        status: json['status']?.toString(),
        nextTransferAt: json['nextTransferAt']?.toString() ??
            json['nextPayoutAt']?.toString(),
      );
}

class SettlementOrder {
  final String id;
  final String orderNumber;
  final double itemValue;
  final double commission;
  final double restaurantShare;
  final String? commissionBand;
  final bool capApplied;
  final String? placedAt;

  SettlementOrder({
    required this.id,
    required this.orderNumber,
    required this.itemValue,
    required this.commission,
    required this.restaurantShare,
    this.commissionBand,
    this.capApplied = false,
    this.placedAt,
  });

  factory SettlementOrder.fromJson(Map<String, dynamic> json) {
    final itemValue = _toDouble(
      json['itemValue'] ?? json['total'] ?? json['orderTotal'],
    );
    final commission = _toDouble(json['commission'] ?? json['platformFee']);
    final restaurantShare = _toDouble(
      json['restaurantShare'] ?? json['netAmount'] ?? (itemValue - commission),
    );

    return SettlementOrder(
      id: json['orderId']?.toString() ?? json['id']?.toString() ?? '',
      orderNumber:
          json['orderNumber']?.toString() ?? json['orderId']?.toString() ?? '',
      itemValue: itemValue,
      commission: commission,
      restaurantShare: restaurantShare,
      commissionBand: json['commissionBand']?.toString(),
      capApplied: json['capApplied'] == true,
      placedAt: json['placedAt']?.toString() ?? json['createdAt']?.toString(),
    );
  }
}

class RecentPayout {
  final String id;
  final String reference;
  final double amount;
  final String status;
  final String? paidAt;
  final String? bankName;
  final String? accountLast4;

  RecentPayout({
    required this.id,
    required this.reference,
    required this.amount,
    required this.status,
    this.paidAt,
    this.bankName,
    this.accountLast4,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';

  factory RecentPayout.fromJson(Map<String, dynamic> json) {
    final account = json['bankAccountNumber']?.toString() ??
        json['accountNumber']?.toString() ??
        json['accountLast4']?.toString();

    return RecentPayout(
      id: json['id']?.toString() ?? json['payoutId']?.toString() ?? '',
      reference: json['reference']?.toString() ??
          json['payoutNumber']?.toString() ??
          json['id']?.toString() ??
          '',
      amount: _toDouble(json['amount'] ?? json['netAmount'] ?? json['payout']),
      status: json['status']?.toString() ?? 'PAID',
      paidAt: json['paidAt']?.toString() ??
          json['createdAt']?.toString() ??
          json['transferDate']?.toString(),
      bankName: json['bankName']?.toString(),
      accountLast4: account != null && account.length >= 4
          ? account.substring(account.length - 4)
          : account,
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
