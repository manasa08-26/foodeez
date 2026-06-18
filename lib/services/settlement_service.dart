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

  Future<SettlementSummary> getSummary(SettlementPeriod period) async {
    try {
      final res = await _dio.get(ApiEndpoints.settlementSummary(period.apiPath));
      return SettlementSummary.fromJson(_unwrapMap(res.data));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<SettlementOrder>> getOrders(SettlementPeriod period) async {
    try {
      final res = await _dio.get(ApiEndpoints.settlementOrders(period.apiPath));
      return _toList(res.data)
          .map((e) => SettlementOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<RecentPayout>> getRecentPayouts({int limit = 10}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.settlementRecentPayouts,
        queryParameters: {'limit': limit},
      );
      return _toList(res.data)
          .map((e) => RecentPayout.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> requestWithdraw() async {
    try {
      await _dio.post(ApiEndpoints.settlementWithdraw);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ApiException('Withdraw is not available yet', statusCode: 404);
      }
      throw ApiException.fromDioError(e);
    }
  }

  static Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      if (data['summary'] is Map) {
        return Map<String, dynamic>.from(data['summary'] as Map);
      }
      return data;
    }
    return {};
  }

  static List _toList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in [
        'payouts',
        'orders',
        'data',
        'items',
        'results',
        'records',
      ]) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }
}
