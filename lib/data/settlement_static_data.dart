import '../models/restaurant_model.dart';
import '../models/settlement_model.dart';

/// Preview data for the payouts screen until partner settlement APIs are live.
class SettlementStaticData {
  SettlementStaticData._();

  /// Flip to `true` when payout APIs are ready.
  static const bool useLiveApis = false;

  static SettlementSummary summary(SettlementPeriod period) {
    final nextTransfer = _tomorrowAtTenAm().toIso8601String();

    return switch (period) {
      SettlementPeriod.today => SettlementSummary(
          orderCount: 47,
          totalItemValue: 18420,
          totalCommission: 921,
          totalRestaurantShare: 17499,
          taxesAndAdjustments: 0,
          status: 'SETTLED',
          nextTransferAt: nextTransfer,
        ),
      SettlementPeriod.week => SettlementSummary(
          orderCount: 312,
          totalItemValue: 128460,
          totalCommission: 6423,
          totalRestaurantShare: 122037,
          taxesAndAdjustments: 0,
          status: 'SETTLED',
          nextTransferAt: nextTransfer,
        ),
      SettlementPeriod.month => SettlementSummary(
          orderCount: 1284,
          totalItemValue: 502680,
          totalCommission: 25134,
          totalRestaurantShare: 477546,
          taxesAndAdjustments: 0,
          status: 'SETTLED',
          nextTransferAt: nextTransfer,
        ),
    };
  }

  static List<RecentPayout> recentPayouts() {
    final now = DateTime.now();
    return [
      RecentPayout(
        id: '1',
        reference: 'PYT-2418',
        amount: 14250,
        status: 'PAID',
        paidAt: DateTime(now.year, now.month, now.day - 1).toIso8601String(),
        bankName: 'HDFC',
        accountLast4: '4421',
      ),
      RecentPayout(
        id: '2',
        reference: 'PYT-2417',
        amount: 12900,
        status: 'PAID',
        paidAt: DateTime(now.year, now.month, now.day - 2).toIso8601String(),
        bankName: 'HDFC',
        accountLast4: '4421',
      ),
      RecentPayout(
        id: '3',
        reference: 'PYT-2416',
        amount: 11840,
        status: 'PAID',
        paidAt: DateTime(now.year, now.month, now.day - 3).toIso8601String(),
        bankName: 'HDFC',
        accountLast4: '4421',
      ),
    ];
  }

  static RestaurantModel bankPreview() => RestaurantModel(
        id: 'preview',
        name: 'Foodeez Restaurant',
        bankName: 'HDFC',
        bankAccountNumber: '00000000004421',
      );

  static DateTime _tomorrowAtTenAm() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 10);
  }
}
