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
      return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> getOrder(String orderId) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.restaurantOrder(orderId));
      return OrderModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> updateOrderStatus(
      String orderId, String status) async {
    try {
      final res = await _dio.patch(
          ApiEndpoints.restaurantOrderStatus(orderId),
          data: {'status': status});
      return OrderModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // KDS operations
  Future<List<OrderModel>> getLiveOrders() async {
    try {
      final res = await _dio.get(ApiEndpoints.partnerOrders);
      final list = _toList(res.data);
      return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
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

  Future<OrderModel> acceptOrder(
      String orderId, int prepTimeMinutes) async {
    try {
      final res = await _dio.patch(
          ApiEndpoints.partnerOrderAccept(orderId),
          data: {'prepTimeMinutes': prepTimeMinutes});
      return OrderModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> rejectOrder(String orderId, String reason) async {
    try {
      final res = await _dio.patch(
          ApiEndpoints.partnerOrderReject(orderId),
          data: {'reason': reason});
      return OrderModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderModel> markReady(String orderId) async {
    try {
      final res =
          await _dio.patch(ApiEndpoints.partnerOrderReady(orderId));
      return OrderModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
