import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/restaurant_model.dart';
import '../models/user_model.dart';
import '../models/dashboard_model.dart';

final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService(ref.read(dioProvider));
});

class RestaurantService {
  final Dio _dio;
  RestaurantService(this._dio);

  Future<RestaurantModel> getRestaurant(String id) async {
    try {
      final res = await _dio.get(ApiEndpoints.restaurant(id));
      return RestaurantModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<RestaurantModel> updateRestaurant(
      String id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch(ApiEndpoints.restaurant(id), data: data);
      return RestaurantModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OnboardingStatus> getOnboarding(String restaurantId) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.restaurantOnboarding(restaurantId));
      return OnboardingStatus.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<UserModel>> getRestaurantUsers(String restaurantId) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.restaurantUsers(restaurantId));
      final list = _toList(res.data);
      return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  static List _toList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['users', 'data', 'items', 'results']) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }

  Future<UserModel> createRestaurantUser(
      String restaurantId, Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(
          ApiEndpoints.restaurantUsers(restaurantId),
          data: data);
      return UserModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DashboardMetrics> getDashboard() async {
    try {
      final res = await _dio.get(ApiEndpoints.dashboard);
      return DashboardMetrics.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Returns raw JSON map from /dashboard — used by the live dashboard UI
  /// so it can flexibly read any field the backend returns.
  Future<Map<String, dynamic>> getRawDashboard() async {
    try {
      final res = await _dio.get(ApiEndpoints.dashboard);
      if (res.data is Map<String, dynamic>) return res.data;
      return {};
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
