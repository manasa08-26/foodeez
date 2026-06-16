import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/settlement_model.dart';

final settlementServiceProvider = Provider<SettlementService>((ref) {
  return SettlementService(ref.read(dioProvider));
});

class SettlementService {
  final Dio _dio;
  SettlementService(this._dio);

  /// Fetches today's completed orders from the restaurant orders endpoint
  /// and computes settlement summary from them.
  Future<List<SettlementOrder>> getTodayOrders() async {
    try {
      final res = await _dio.get(
        ApiEndpoints.restaurantOrders,
        queryParameters: {
          'status': 'DELIVERED',
          'limit': 100,
          'page': 1,
        },
      );
      final list = _toList(res.data);
      return list
          .map((e) => SettlementOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SettlementSummary> getTodaySummary() async {
    final orders = await getTodayOrders();
    final today = DateTime.now();
    final todayOrders = orders.where((o) {
      try {
        final d = DateTime.parse(o.createdAt ?? '');
        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day;
      } catch (_) {
        return true; // include if we can't parse date
      }
    }).toList();

    final gross = todayOrders.fold<double>(0, (s, o) => s + o.total);
    const platformFee = 0.05; // 5% platform fee
    final fee = gross * platformFee;
    final net = gross - fee;

    return SettlementSummary(
      grossRevenue: gross,
      platformFee: fee,
      netPayout: net,
      totalOrders: todayOrders.length,
      pendingOrders: 0,
    );
  }

  static List _toList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['orders', 'data', 'items', 'results']) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }
}
