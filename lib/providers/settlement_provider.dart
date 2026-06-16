import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settlement_model.dart';
import '../services/settlement_service.dart';

final settlementSummaryProvider =
    FutureProvider.autoDispose<SettlementSummary>((ref) async {
  return ref.read(settlementServiceProvider).getTodaySummary();
});

final settlementOrdersProvider =
    FutureProvider.autoDispose<List<SettlementOrder>>((ref) async {
  return ref.read(settlementServiceProvider).getTodayOrders();
});
