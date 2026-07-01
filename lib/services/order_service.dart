import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/order_model.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.read(dioProvider));
});

class OrderService {
  final Dio _dio;
  OrderService(this._dio);

  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.restaurantOrders,
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      final list = _toList(res.data);
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> getOrder(String orderId) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.restaurantOrder(orderId));
      return _parseOrder(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> updateOrderStatus(
    String orderId,
    String status, {
    String? note,
  }) async {
    try {
      final res = await _dio.patch(
        ApiEndpoints.restaurantOrderStatus(orderId),
        data: {
          'status': status,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      return _parseOrder(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // KDS operations
  Future<List<OrderModel>> getLiveOrders() async {
    try {
      final res = await _dio.get(ApiEndpoints.partnerOrders);
      final list = _toList(res.data);
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Handles all common API list response shapes:
  /// - plain array: [...]
  /// - {orders:[...]}, {data:[...]}, {items:[...]}, {results:[...]}
  static List _toList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['orders', 'data', 'items', 'results', 'records']) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }

  static OrderModel _parseOrder(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final nested = map['order'] ?? map['data'];
      if (nested is Map) {
        return OrderModel.fromJson(Map<String, dynamic>.from(nested));
      }
      if (map.containsKey('id')) {
        return OrderModel.fromJson(map);
      }
    }
    throw const FormatException('Unexpected order response shape');
  }

  Future<OrderModel> acceptOrder(
      String orderId, int prepTimeMinutes) async {
    try {
      final res = await _dio.patch(
          ApiEndpoints.partnerOrderAccept(orderId),
          data: {'prep_time_minutes': prepTimeMinutes});
      return _parseOrder(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> rejectOrder(String orderId, String reason) async {
    try {
      final res = await _dio.patch(
          ApiEndpoints.partnerOrderReject(orderId),
          data: {'reason': reason});
      return _parseOrder(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> markReady(String orderId) async {
    try {
      final res =
          await _dio.patch(ApiEndpoints.partnerOrderReady(orderId));
      return _parseOrder(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
