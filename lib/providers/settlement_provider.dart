import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settlement_static_data.dart';
import '../models/restaurant_model.dart';
import '../models/settlement_model.dart';
import '../providers/auth_provider.dart';
import '../services/restaurant_service.dart';
import '../services/settlement_service.dart';

final settlementSummaryByPeriodProvider = FutureProvider.autoDispose
    .family<SettlementSummary, SettlementPeriod>((ref, period) async {
  if (!SettlementStaticData.useLiveApis) {
    return SettlementStaticData.summary(period);
  }
  return ref.read(settlementServiceProvider).getSummary(period);
});

final settlementOrdersByPeriodProvider = FutureProvider.autoDispose
    .family<List<SettlementOrder>, SettlementPeriod>((ref, period) async {
  if (!SettlementStaticData.useLiveApis) {
    return const [];
  }
  return ref.read(settlementServiceProvider).getOrders(period);
});

final recentPayoutsProvider =
    FutureProvider.autoDispose<List<RecentPayout>>((ref) async {
  if (!SettlementStaticData.useLiveApis) {
    return SettlementStaticData.recentPayouts();
  }
  return ref.read(settlementServiceProvider).getRecentPayouts();
});

final settlementRestaurantProvider =
    FutureProvider.autoDispose<RestaurantModel?>((ref) async {
  if (!SettlementStaticData.useLiveApis) {
    return SettlementStaticData.bankPreview();
  }

  final restaurantId = ref.watch(restaurantIdProvider);
  if (restaurantId == null || restaurantId.isEmpty) return null;
  return ref.read(restaurantServiceProvider).getRestaurant(restaurantId);
});
